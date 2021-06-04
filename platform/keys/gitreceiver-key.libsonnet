local k = import 'k.libsonnet';

{
  conf(name, key):: k.core.v1.secret.new(
    name='gitreceiver-private-key',
    data={
      key: key,
    }
  ).withNamespace('platform')
  .withLabels({ 'app.kubernetes.io/managed-by': 'Helm' })
    .withAnnotations({ 'meta.helm.sh/release-name': name,
        'meta.helm.sh/release-namespace': 'default' }),
}
