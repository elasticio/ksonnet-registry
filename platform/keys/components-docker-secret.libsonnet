local k = import 'k.libsonnet';

{
  conf(username, password, email, registry='https://index.docker.io/v1/'):: k.core.v1.secret.new(
    name='elasticiotasks',
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
  ).withNamespace('tasks')
}
