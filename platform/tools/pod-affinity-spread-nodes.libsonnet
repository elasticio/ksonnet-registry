{
  call(appLabelValue, appLabelKey='app') :: {
    affinity: {
      podAntiAffinity: {
        preferredDuringSchedulingIgnoredDuringExecution: [
          {
            weight: 100,
            podAffinityTerm: {
              labelSelector: {
              matchExpressions: [
                {
                  key: appLabelKey,
                  operator: 'In',
                  values: [
                    appLabelValue,
                  ],
                },
              ],
            },
            topologyKey: 'kubernetes.io/hostname',
          },
        },
      ],
    },
  },
}
}
