import boto3

def extract_instance_ids(instances):
    instance_ids = []
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    return instance_ids

def main():
    ec2 = boto3.client('ec2')

    # 태그 이름에 'engine-dev'가 포함된 인스턴스만 필터링
    filters = [
        {
            'Name': 'tag:Name',
            'Values': ['*engine-prod*']
        }
    ]
    response = ec2.describe_instances(Filters=filters)
    instance_ids = extract_instance_ids(response)
    
    # 작은따옴표 형식으로 출력
    # print(instance_ids)

    # 큰따옴표 형식으로 출력
    formatted_instance_ids = ', '.join(f'"{id_}"' for id_ in instance_ids)
    print(formatted_instance_ids)

if __name__ == "__main__":
    main()