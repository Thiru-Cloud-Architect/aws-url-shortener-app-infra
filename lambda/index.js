const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client 		= new DynamoDBClient();
const ddbDocClient 	= DynamoDBDocumentClient.from(client);

const TABLE_NAME	= process.env.TABLE_NAME;
const AUTH_TOKEN	= process.env.AUTH_TOKEN;

const handler = async (event) => {
	const method = event.requestContext.http.method;

	if ( method == "POST") {
		const authHeader = event.headers.authorization;
		if (authHeader != AUTH_TOKEN) {
			return {
				statusCode: 401,
				body: JSON.stringify({ error: "Unauthorized" })
			};
		}

		let body;
		try {
			body = JSON.parse(event.body);
		} catch (error) {
			return {
				statusCode: 400,
				body: JSON.stringify({ error: "Invalid JSON" })
			};
		}

		if (!body.URL) {
			return {
				statusCode: 400,
				body: JSON.stringify({ error: "URL is required" })
			};
		}

		const shortCode = Math.random().toString(36).substring(2, 8);

		await ddbDocClient.send(
			new PutCommand({ 
				TableName: TABLE_NAME, 
				Item: { 
					short_url: shortCode, URL: body.URL 
				} 
			})
		);

		return {
			statusCode: 200,
			body: JSON.stringify({ short_url: shortCode })
		};	
	}

	if (method == "GET") {
		const code = event.pathParameters?.short_url;

		const { Item } = await ddbDocClient.send(
			new GetCommand({ 
				TableName: TABLE_NAME, 
				Key: { short_url: code } 
			})
		);

		if (!Item) {
			return {
				statusCode: 404,
				body: JSON.stringify({ error: "Not found" })
			};
		}

		return {
			statusCode: 302,
			headers: { Location: Item.URL },
		};
	}

	return {
		statusCode: 405,
		body: JSON.stringify({ error: "Method not allowed" })
	};	
}

module.exports = { handler };
