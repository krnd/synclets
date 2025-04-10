# python.schema.build.ps1 1.1
#Requires -Version 5.1


# ################################ CONFIGURATION ###############################

CONFIGURE python.schema.models `
    -Default $null

CONFIGURE python.schema.basepath `
    -Default ""


# ################################ TASKS #######################################

TASK python:schema:build python:venv:activate, {
    $Models = (CONF python.schema.models)
    $BasePath = (CONF python.schema.basepath)

    $Models.PSObject.Properties | ForEach-Object {
        $ModelFile, $SchemaFile = $_.Name, $_.Value

        if ($BasePath) {
            $ModelFile = (Join-Path $BasePath $ModelFile)
            $SchemaFile = (Join-Path $BasePath $SchemaFile)
        }

        EXEC {
            datamodel-codegen `
                --use-schema-description `
                --use-field-description `
                --input $SchemaFile `
                --input-file-type jsonschema `
                --output $ModelFile `
                --output-model-type typing.TypedDict
        }
    }
}
