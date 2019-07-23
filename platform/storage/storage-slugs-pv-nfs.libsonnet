{
  conf(pvName, server, path, storage='1Ti', pvGid=1502):: [{
      kind: 'PersistentVolume',
      apiVersion: 'v1',
      metadata: {
        name: pvName,
        namespace: 'platform',
        annotations: {
          'pv.beta.kubernetes.io/gid': std.toString(pvGid),
        },
      },
      spec: {
        storageClassName: 'platform-storage-slugs',
        capacity: {
          storage: storage,
        },
        accessModes: [
          'ReadWriteMany',
        ],
        nfs: {
          path: path,
          server: server,
        },
      },
    }]
}
