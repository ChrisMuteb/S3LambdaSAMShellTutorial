BUCKET_NAME="s3lambdashellcf"
JAR_FILE="target/s3lambdashellcf-1.0-SNAPSHOT.jar"
S3_KEY="$BUCKET_NAME/s3lambdashellcf-1.0-SNAPSHOT.jar"
PATH_TO_JAR=""
TEMPLATE_FILE="template.yaml"
PACKAGED_TEMPLATE_FILE="packaged.yaml"


# Create an S3 bucket
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME

# Build the project & package it as a JAR file using maven
echo "Packaging the application with Maven"
mvn clean package

# Check if the JAR file was created
if [ ! -f "$JAR_FILE" ]; then
  echo "JAR file not found: $JAR_FILE"
  exit 1
fi

# Upload the JAR file to the S3 bucket
echo "Uploading Cloudformation template with S3 bucket and key"
aws s3 cp $JAR_FILE s3://$BUCKET_NAME

# Package the cloudformation template with S3 bucket & key
echo "Packaging Cloudformation template"
sam package --template-file $TEMPLATE_FILE --s3-bucket $BUCKET_NAME --output-template-file generated/$PACKAGED_TEMPLATE_FILE

# Deploy the Cloudformation stack
echo "Deploying Cloudformation stack"
sam deploy --template-file $PACKAGED_TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM

echo "Deployment completed successfully"

