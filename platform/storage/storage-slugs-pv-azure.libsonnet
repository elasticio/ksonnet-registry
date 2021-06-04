{
  conf(name, pvName, accountName, accountKey, shareName, storage='1Ti', pvGid=1502):: [
      {
        apiVersion: 'v1',
        data: {
          azurestorageaccountkey: std.base64(accountKey),
          azurestorageaccountname: std.base64(accountName),
        },
        kind: 'Secret',
        metadata: {
          name: 'azure-storage-secret',
          namespace: 'platform',
          annotations: {
           'meta.helm.sh/release-name': name,
           'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
           'app.kubernetes.io/managed-by': 'Helm',
          }
        },
        type: 'Opaque',
      },
      {
        kind: 'PersistentVolume',
        apiVersion: 'v1',
        metadata: {
          name: pvName,
          namespace: 'platform',
          annotations: {
            'pv.beta.kubernetes.io/gid': std.toString(pvGid),
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
           'app.kubernetes.io/managed-by': 'Helm',
          }
        },
        spec: {
          storageClassName: 'platform-storage-slugs',
          capacity: {
            storage: storage,
          },
          accessModes: [
            'ReadWriteMany',
          ],
          azureFile: {
            secretName: 'azure-storage-secret',
            secretNamespace: null,
            shareName: shareName,
          },
          mountOptions: [
            'dir_mode=0775',
            'file_mode=0775',
            'gid=' + pvGid,
            'noperm',
          ],
        },
      },
    ]
}
