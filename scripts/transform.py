from frictionless import Package, Schema, fields
import logging
import petl as etl
from dpm.utils import as_identifier
from scripts.pipelines import transform_pipeline

logger = logging.getLogger(__name__)

# resource_name = 'uo' # para rodar no modo interativo

def transform_resource(resource_name: str, source_descriptor: str = 'datapackage.yaml'):
    logger.info(f'Transforming resource {resource_name}')

    package = Package(source_descriptor)
    resource = package.get_resource(resource_name)
    schema = Schema.from_descriptor(f'schemas/{resource_name}.yaml')
    resource.transform(transform_pipeline)
    table = resource.to_petl()

    for field in resource.schema.fields:
        target = field.custom.get('target')
        target = target if target else as_identifier(field.name)
        table = etl.rename(table, field.name, target)
        table = etl.select(table, "ano", lambda v: v >= 2008)

    if resource_name == "elemento_item":

        table = etl.selectnotnone(table, "elemento_item_desc")
        table = etl.distinct(table)

    if resource_name == "funcional_programatica":
        table = etl.select(
            table, lambda row: row.ano == 2023 and row.uo_cod == 1401 and row.funcao_cod == 12 and row.acao_cod == 4302, complement = True
        )

    if resource_name == "uo":
        table = etl.convert(table, 'ano', int)
        table = etl.convert(table, 'uo_cod', int)
        max_uo_cod_ano = table.cut('uo_cod', 'ano').rowreduce(key='uo_cod', reducer=lambda key, rows: (key, max(row['ano'] for row in rows)), header=['uo_cod', 'max_ano'])

        print("max_uo_cod_ano before join:")
        print(list(etl.data(max_uo_cod_ano.cut('uo_cod', 'max_ano'))))  # Ensure these columns exist

        print("table before join:")
        print(list(etl.data(table.cut('uo_cod', 'ano', 'uo_sigla'))))

        uo_sigla_current = etl.leftjoin(max_uo_cod_ano, table, lkey=['uo_cod', 'max_ano'], rkey=['uo_cod', 'ano']).cut('uo_cod', 'uo_sigla').rename('uo_sigla', 'uo_sigla_current').cache()

        print("uo_sigla_current after join:")
        print(list(etl.data(uo_sigla_current)) if uo_sigla_current else "None")

        table = table.leftjoin(uo_sigla_current, key='uo_cod')

    table = etl.addfield(table, f'chave_{resource.name}', lambda row: '|'.join(str(row[key]) for key in schema.primary_key), index=0)

    etl.tocsv(table, f'data/{resource.name}.csv', encoding='utf-8')
