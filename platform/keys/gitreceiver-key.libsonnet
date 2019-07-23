local k = import 'k.libsonnet';

{
  conf(key):: k.core.v1.secret.new(
    name='gitreceiver-private-key',
    data={
      key: key,
    }
  ).withNamespace('platform'),
}
