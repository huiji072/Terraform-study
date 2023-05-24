import boto3

def list_ecs_cluster_names():
    ecs = boto3.client('ecs')
    response = ecs.list_clusters()
    cluster_arns = response['clusterArns']
    # 모든 클러스터 이름 
    cluster_names = [arn.split('/')[-1] for arn in cluster_arns]
    # 해당 단어만 포함한 클러스터 이름
    # cluster_names = [arn.split('/')[-1] for arn in cluster_arns if 'server' in arn]

    return cluster_names

if __name__ == "__main__":
    cluster_names = list_ecs_cluster_names()
    for name in cluster_names:
        print(name)djs