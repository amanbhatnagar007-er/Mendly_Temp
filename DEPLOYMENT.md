# Deploy Mendaly

The deployment uses Vercel for the Vite web app and Render for the FastAPI service. The Render API requires HTTP Basic credentials, fails closed if its credentials are missing, and stores SQLite data on a persistent disk. The web app asks for those credentials at sign-in and keeps them in the current browser tab session.

## Render API

1. Create a Render Blueprint from this repository and select `render.yaml`.
2. Enter a username and a long, unique password when Render requests the two unsynchronized environment variables. Keep the password in a password manager.
3. Deploy `mendaly-api`. Wait for `/healthz` to report healthy.

The Blueprint uses a persistent disk mounted at `/var/data`; do not remove that disk when updating the service or the SQLite database will be lost.

## Vercel web app

1. Import the same repository into Vercel and set the project root directory to `frontend`.
2. Use Vite's default build command `npm run build` and output directory `dist`.
3. In `frontend/vercel.json`, replace `mendaly-api.onrender.com` with the hostname Render assigned to your API.
4. Set the Vercel environment variable `VITE_REQUIRE_LOGIN` to `true`, then deploy or redeploy the project.
5. Open the Vercel URL and sign in with the Render username/password.

The `/api/*` rewrite keeps browser requests on the Vercel origin while proxying them to Render, so the browser does not need a permissive cross-origin API configuration. Keep `MENDALY_REQUIRE_AUTH=1` on Render. If the username or password is absent, the API returns `503` instead of exposing stored data.

## Local development

The auth gate is disabled by default for local work. Run the API on port `8000` and the Vite server on `5173`; Vite proxies `/api/*` to the API. Set `VITE_REQUIRE_LOGIN=true` in a local `.env` only when testing the sign-in flow against an API configured with credentials.
