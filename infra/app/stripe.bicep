
param name string
param location string = resourceGroup().location
param tags object = {}

param apiUrl string
param portalUrl string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param stripeImageName string = ''
param serviceName string = 'stripe'

param stripePublicKey string
@secure()
param stripeSecretKey string
@secure()
param stripeWebhookSecret string

module stripe '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    secrets: [
      {
        name: 'APPINSIGHTS_CS'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'STRIPE_PUBLIC_KEY'
        value: stripePublicKey
      }
      {
        name: 'STRIPE_SECRET_KEY'
        value: stripeSecretKey
      }
      {
        name: 'STRIPE_WEBHOOK'
        value: stripeWebhookSecret
      }
    ]
    env: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: 'secretref:APPINSIGHTS_CS'
      }
      {
        name: 'API_URL'
        value: apiUrl
      }
      {
        name: 'WEB_APP_URL'
        value: portalUrl
      }
      {
        name: 'STRIPE_PUBLIC_KEY'
        value: 'secretref:STRIPE_PUBLIC_KEY'
      }
      {
        name: 'STRIPE_SECRET_KEY'
        value: 'secretref:STRIPE_SECRET_KEY'
      }
      {
        name: 'STRIPE_WEBHOOK_SECRET'
        value: 'secretref:STRIPE_WEBHOOK'
      }
    ]
    imageName: !empty(stripeImageName) ? stripeImageName : 'nginx:latest'
    targetPort: 4242
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output SERVICE_STRIPE_NAME string = stripe.outputs.name
output SERVICE_STRIPE_URI string = stripe.outputs.uri
output SERVICE_STRIPE_IMAGE_NAME string = stripe.outputs.imageName
