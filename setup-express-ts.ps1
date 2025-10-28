#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# === Ask for directory and project name ===
$targetDir = Read-Host "[?] Enter the full directory path where you want to create the project"
$appName = Read-Host "[?] Enter the project name"
$port = Read-Host "[?] Enter your server port (default: 3000)"
if (-not $port) { $port = "3000" }
$dbUrl = Read-Host "[?] Enter your MongoDB connection URL (or leave blank for default)"
if (-not $dbUrl) { $dbUrl = "mongodb://localhost:27017/testdb" }

# === Check or create base directory ===
if (-not (Test-Path $targetDir)) {
    Write-Host "[!] Directory does not exist. Creating it..."
    New-Item -ItemType Directory -Path $targetDir
}

# === Create full project path ===
$projectPath = Join-Path $targetDir $appName

# === Overwrite check ===
if (Test-Path $projectPath) {
    $overwrite = Read-Host "[!] Folder already exists. Overwrite? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "[x] Aborted."
        exit
    } else {
        Write-Host "[!] Removing existing folder..."
        Remove-Item -Recurse -Force $projectPath
    }
}

# === Create project folder and move there ===
Write-Host "[*] Creating project folder..."
New-Item -ItemType Directory -Path $projectPath
Set-Location $projectPath

# === Initialize npm ===
Write-Host "[*] Initializing npm..."
npm init -y

# === Install Dependencies ===
Write-Host "[*] Installing dependencies: express, mongoose, cors, helmet, morgan, dotenv..."
npm install express mongoose cors helmet morgan dotenv

Write-Host "[*] Installing dev dependencies: typescript, ts-node, nodemon, @types/*..."
npm install -D typescript ts-node nodemon @types/node @types/express @types/cors @types/helmet @types/morgan

# === Initialize TypeScript ===
Write-Host "[*] Initializing TypeScript..."
npx tsc --init

# === tsconfig.json ===
Write-Host "[*] Creating tsconfig.json..."
$tsconfig = @"
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "esModuleInterop": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true
  }
}
"@
$tsconfig | Out-File -Encoding utf8 tsconfig.json
Write-Host "[OK] tsconfig.json created."

# === Create folders ===
$folders = @("src", "src/config", "src/middleware", "src/routes", "src/controllers", "src/services", "src/utils", "src/types","src/schemas")
Write-Host "[*] Creating project folder structure..."
foreach ($folder in $folders) {
    Write-Host "  -> Creating folder: $folder"
    New-Item -ItemType Directory -Path $folder
}

# === .gitignore ===
Write-Host "[*] Creating .gitignore..."
@"
node_modules
dist
.env
"@ | Out-File -Encoding utf8 ".gitignore"

# === Initialize Git ===
Write-Host "[*] Initializing Git repository..."
git init
Write-Host "[OK] Git repository initialized."

# === .env ===
Write-Host "[*] Creating .env..."
@"
PORT=$port
DB_URL=$dbUrl
"@ | Out-File -Encoding utf8 ".env"

# === src/config/env.ts ===
Write-Host "[*] Creating src/config/env.ts..."
@"
import dotenv from 'dotenv';
dotenv.config();

const required = ['DB_URL', 'PORT'];

for (const key of required) {
  if (!process.env[key]) {
    throw new Error('Missing environment variable: ' + key);
  }
}

export const ENV = {
  DB_URL: process.env.DB_URL!,
  PORT: process.env.PORT || '3000',
};
"@ | Out-File -Encoding utf8 "src/config/env.ts"

# === src/middleware/errorHandler.ts ===
Write-Host "[*] Creating src/middleware/errorHandler.ts..."
@"
import { Request, Response, NextFunction } from 'express';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  console.error('[ERROR]', err);
  res.status(err.status || 500).json({ message: err.message || 'Internal Server Error' });
};
"@ | Out-File -Encoding utf8 "src/middleware/errorHandler.ts"

# === src/index.ts ===
Write-Host "[*] Creating src/index.ts..."
@"
import express from 'express';
import mongoose from 'mongoose';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import { ENV } from './config/env';
import { errorHandler } from './middleware/errorHandler';

const app = express();
app.use(express.json());
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));

mongoose.connect(ENV.DB_URL)
  .then(() => console.log('[OK] Connected to MongoDB'))
  .catch((err) => console.error('[DB ERROR]', err));

app.get('/', (req, res) => {
  res.send('TypeScript + Express + MongoDB = READY');
});

app.use(errorHandler);

app.listen(ENV.PORT, () => {
  console.log('[OK] Server running on port ' + ENV.PORT);
});
"@ | Out-File -Encoding utf8 "src/index.ts"

# === Add scripts ===
Write-Host "[*] Adding npm scripts..."
npm pkg set scripts.dev="nodemon --watch src --exec ts-node src/index.ts"
npm pkg set scripts.build="tsc"
npm pkg set scripts.start="node dist/index.js"

# === ESLint + Prettier ===
Write-Host "[*] Installing ESLint + Prettier..."
npm install -D eslint prettier eslint-config-prettier eslint-plugin-prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin

Write-Host "[*] Configuring ESLint..."
$eslintConfig = @"
{
  "env": { "browser": true, "es2021": true, "node": true },
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended", "plugin:prettier/recommended"],
  "parser": "@typescript-eslint/parser",
  "parserOptions": { "ecmaVersion": "latest", "sourceType": "module" },
  "plugins": ["@typescript-eslint"],
  "rules": {}
}
"@
$eslintConfig | Out-File -Encoding utf8 ".eslintrc.json"
Write-Host "[OK] ESLint configured."

Write-Host "[*] Configuring Prettier..."
$prettierConfig = @"
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100
}
"@
$prettierConfig | Out-File -Encoding utf8 ".prettierrc"
Write-Host "[OK] Prettier configured."

# === README.md ===
Write-Host "[*] Creating README.md..."
$readme = @"
# $appName

A TypeScript + Express + MongoDB project generated with Essam's PowerShell setup.

## Scripts
- npm run dev   -> start development server
- npm run build -> compile TypeScript
- npm start     -> run compiled JS

## Environment
Create a .env file with:
PORT=$port
DB_URL=$dbUrl
"@
$readme | Out-File -Encoding utf8 "README.md"
Write-Host "[OK] README.md created."

# === VS Code launch config ===
Write-Host "[*] Creating VS Code launch configuration..."
New-Item -ItemType Directory -Path ".vscode" -Force
$launchConfig = @"
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Debug TS",
      "program": "\${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["\${workspaceFolder}/dist/**/*.js"]
    }
  ]
}
"@
$launchConfig | Out-File -Encoding utf8 ".vscode/launch.json"
Write-Host "[OK] VS Code launch configuration added."

# === Summary ===
Write-Host ""
Write-Host "==========================================="
Write-Host "  Express + TypeScript Project Setup Done  "
Write-Host "==========================================="
Write-Host ""
Write-Host "[Path]  $projectPath"
Write-Host ""
Write-Host "[Dependencies] express, mongoose, cors, helmet, morgan, dotenv"
Write-Host "[Dev Dependencies] typescript, ts-node, nodemon, @types/*, eslint, prettier, @typescript-eslint/*"
Write-Host ""
Write-Host "[Structure]"
foreach ($folder in $folders) { Write-Host "  - $folder" }
Write-Host ""
Write-Host "[Scripts]"
Write-Host "  npm run dev   -> start development server"
Write-Host "  npm run build -> compile TypeScript"
Write-Host "  npm start     -> run compiled JS"
Write-Host ""
Write-Host "[INFO] Setup completed successfully."

# === ASCII BANNER ===
Write-Host ""
Write-Host "==========================================="
Write-Host "      PROJECT CREATED BY ESSAM         "
Write-Host "==========================================="
Write-Host ""
Write-Host "          |\\_/|        "
Write-Host "          | o o|        "
Write-Host "          (  T )        "
Write-Host "         .^~^~^~^.      "
Write-Host "        /   BUILD   \\   "
Write-Host "       (   SUCCESS!  )  "
Write-Host "        \\__________/    "
Write-Host ""
Write-Host ""

# === Wait before opening VS Code ===
Read-Host "`nPress ENTER to open the project in VS Code"
code $projectPath
