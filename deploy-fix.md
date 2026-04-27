# Deployment Fix Instructions

## Problem
Your Render deployment is using a different database than your local development, causing:
- Workers created locally don't appear in production
- Login attempts fail because workers don't exist in production database

## Solution
The production configuration needs to be updated to use your Supabase database.

## Files Updated
- `Vari-Backend/src/main/resources/application-production.properties`

## Manual Deployment Steps
Since git commands aren't working in this environment, you need to:

1. **Go to your Render Dashboard**
2. **Find your `vari-backend` service**
3. **Click "Manual Deploy"** 
4. **Select "Deploy latest commit"**

OR

1. **Push the changes manually:**
   ```bash
   cd Vari-Backend
   git add .
   git commit -m "Fix database configuration - restore Supabase PostgreSQL connection"
   git push
   ```

## Verification
After deployment, test:
- https://vari-backend.onrender.com/api/admin/workers (should show your workers)
- Login with KAV354 should work