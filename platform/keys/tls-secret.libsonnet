local k = import 'k.libsonnet';

{
  conf(name, crt, key):: k.core.v1.secret.new(
    name=name,
    data={
      'tls.crt': crt,
      'tls.key': key,
    },
    type='kubernetes.io/tls'
  ).withNamespace('platform'),
}
