from frictionless import Package
import logging
import petl as etl
from dpm.utils import as_identifier
from scripts.pipelines import transform_pipeline

logger = logging.getLogger(__name__)

def transform_resource(resource_name: str, source_descriptor: str = 'datapackage.yaml'):
    logger.info(f'Transforming resource {resource_name}')
    
    package = Package(source_descriptor)
    resource = package.get_resource(resource_name)
    resource.transform(transform_pipeline)
    table = resource.to_petl()
    for field in resource.schema.fields:
        target = field.custom.get('target')
        target = target if target else as_identifier(field.name)
        table = etl.rename(table, field.name, target)
    etl.tocsv(table, f'data/{resource.name}.csv', encoding='utf-8')
