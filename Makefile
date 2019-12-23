export ENTRYPOINT=terraform
export WORKING_DIR=./
validate_args:
	if [ -z ${WORKING_DIR} ]; then echo "required WORKING_DIR"; exit 1; fi
.env:
	cp env.sample .env
ash: .env
	ENTRYPOINT="" docker-compose run --rm tf ash
v: .env
	docker-compose run --rm tf -v
init: .env validate_args
	docker-compose run --rm tf init
get: .env
	docker-compose run --rm tf get
fmt: .env validate_args
	docker-compose run --rm tf fmt -recursive
plan: .env validate_args
	docker-compose run --rm tf plan
apply: .env validate_args
	docker-compose run --rm tf apply
destroy: .env validate_args
	docker-compose run --rm tf destroy

# aws ecr get-loginは以下のどれかが必要
# $ aws configure
# or
# $ vim ~/.aws/credentials && vim ~/.aws/config
export REPOSITORY_ROOT_PATH=../
login:
	aws ecr get-login --no-include-email | sh
build:
	bash ./cicd/build-pagesearch-solr.sh | tail -1
push: login
	bash ./cicd/build-pagesearch-solr.sh | tail -1 | bash ./cicd/push-pagesearch-solr-to-ecr.sh

configure:
	aws configure --profile readonly
aws-v:
	aws --version
vpc:
	aws ec2 describe-vpcs --profile readonly | jq -r --unbuffered
rt:
	aws ec2 describe-route-tables --profile readonly \
    | jq -r --unbuffered \
      '.RouteTables | map({ rtbid: .RouteTableId, vpcid: .VpcId, tags: .Tags, routes: .Routes })'
nonuse-rt:
	aws ec2 describe-route-tables --profile readonly \
    --query 'RouteTables[?Associations[0].Main != `true`]' | jq -r --unbuffered
