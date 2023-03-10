import (
	"vela/ql"
)

parameter: {
	appName: string
	appNs:   string
}

resources: ql.#ListResourcesInApp & {
	app: {
		name:      parameter.appName
		namespace: parameter.appNs
		filter: {
			"apiVersion": "terraform.core.oam.dev/v1beta2"
			"kind":       "Configuration"
		}
		withStatus: true
	}
}
status: {
	if resources.err == _|_ {
		"cloud-resources": [ for i, resource in resources.list {
			resource.object
		}]
	}
	if resources.err != _|_ {
		error: resources.err
	}
}
