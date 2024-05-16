import { Construct } from 'constructs'
import {
  App,
  TerraformStack,
} from 'cdktf'
import { AwsProvider } from '@cdktf/provider-aws/lib/provider'
import { S3Bucket } from '@cdktf/provider-aws/lib/s3-bucket'

class TestStack extends TerraformStack {


  constructor(scope: Construct, id: string) {
    super(scope, id)

    new AwsProvider(this, 'AWS', {})

    // Create unique S3 bucket that hosts Lambda executable
    new S3Bucket(this, 'bucket', {
      bucketPrefix: `${id}`,
    })
  }
}

const app = new App()
new TestStack(app, `test`)

app.synth()
