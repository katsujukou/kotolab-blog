export async function handler (event, ctx) {
  console.log(event);
  return {
    statusCode: 200,
    body: "Hello from Lambda!"
  }
}