// Placeholder Lambda handler for initial Terraform deployment
// This file is used when creating NEW Lambda functions via Terraform
// After initial deployment, update your Lambda code via your deployment pipeline
//
// Terraform ignores subsequent code changes (ignore_source_code_changes = true by default)

exports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: 'Placeholder Lambda - Deploy your application code via your deployment pipeline',
            environment: process.env.NODE_ENV || 'not-set',
            timestamp: new Date().toISOString(),
        }),
    };
};
