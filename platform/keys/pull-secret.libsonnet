local k = import 'k.libsonnet';

{
  conf(name, username, password, email, registry='https://index.docker.io/v1/'):: k.core.v1.secret.new(
    name='elasticiodevops',
    data={
      '.dockerconfigjson': std.base64(std.toString({
        auths: {
          [registry]: {
            username: username,
            password: password,
            email: email,
            auth: std.base64(std.toString(username + ':' + password)),
          },
        },
      })),
    },
    type='kubernetes.io/dockerconfigjson'
  ).withNamespace('platform')
  .withLabels({ 'app.kubernetes.io/managed-by': 'Helm' })
    .withAnnotations({ 'meta.helm.sh/release-name': name,
        'meta.helm.sh/release-namespace': 'default' })
}
