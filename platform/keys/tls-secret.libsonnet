local k = import 'k.libsonnet';

{
  conf(name, certName, crt, key):: k.core.v1.secret.new(
    name=certName,
    data={
      'tls.crt': crt,
      'tls.key': key,
    },
    type='kubernetes.io/tls'
  ).withNamespace('platform')
  .withLabels({ 'app.kubernetes.io/managed-by': 'Helm' })
    .withAnnotations({ 'meta.helm.sh/release-name': name,
        'meta.helm.sh/release-namespace': 'default' })
}
