import boto3

def list_ecs_services(cluster_name):
    ecs = boto3.client('ecs')
    response = ecs.list_services(cluster=cluster_name)
    service_arns = response['serviceArns']
    service_names = [arn.split('/')[-1] for arn in service_arns]
    
    return service_names

if __name__ == "__main__":
    cluster_name = "YOUR_CLUSTER_NAME" # 크롤링하려는 ECS 클러스터의 이름으로 변경하세요
    service_names = list_ecs_services(cluster_name)
    
    for name in service_names:
        print(name)
