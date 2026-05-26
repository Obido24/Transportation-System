# I-Metro Deployment Guide

## Target architecture
- Public website: `https://ridei-metro.com` on GitHub Pages
- API backend: `https://api.ridei-metro.com` on Contabo
- Admin dashboard: `https://admin.ridei-metro.com` on Contabo

## Website deployment
1. Push the `i_metro/website` folder and `.github/workflows/deploy-website.yml` to GitHub.
2. Enable GitHub Pages using the Actions workflow.
3. Set the custom domain to `ridei-metro.com`.
4. Keep `i_metro/website/CNAME` committed so Pages serves the correct domain.

### DNS for the public site
Point the apex/root domain to GitHub Pages using these A records:
- `185.199.108.153`
- `185.199.109.153`
- `185.199.110.153`
- `185.199.111.153`

Set `www` as a CNAME to `ridei-metro.com`.

## Backend deployment on Contabo
1. Copy the `i_metro/backend` folder to the Contabo server.
2. Set environment variables in `.env`.
3. Use Docker Compose:
   ```bash
   docker compose up -d db
   docker compose up -d --build api
   ```
4. Put Nginx in front of the API and issue SSL:
   ```bash
   sudo certbot --nginx -d api.ridei-metro.com
   ```

### Backend DNS
- `api.ridei-metro.com` -> `109.199.97.98`
- `admin.ridei-metro.com` -> `109.199.97.98`

## Support form
The public support form posts to:
- `POST https://api.ridei-metro.com/api/support/messages/public`

The support page uses `i_metro/website/site-config.js` to switch between local preview and production.

## Environment variables
Required backend variables are listed in `i_metro/backend/.env.example`.

Important ones for support notifications:
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`
- `SMTP_FROM`
- `SUPPORT_EMAIL_TO`

## Local preview
- Website: open the `i_metro/website` folder with a local server.
- Backend: run the Nest app locally or with Docker Compose.
