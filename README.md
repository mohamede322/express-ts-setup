# Express + TypeScript + MongoDB Starter

A **TypeScript + Express + MongoDB** project generated with Essam's PowerShell setup script.
This project is designed to get you up and running quickly with a full TypeScript backend, ESLint + Prettier configured, and a ready-to-use folder structure.

---

## Project Structure

```
src/
  config/
    env.ts
  controllers/
  middleware/
    errorHandler.ts
  routes/
  services/
  utils/
  types/
  schemas/
dist/
node_modules/
.vscode/
.gitignore
.env
tsconfig.json
.eslintrc.json
.prettierrc
README.md
```

* **src/** – Source TypeScript code
* **config/** – Configuration files (env variables)
* **middleware/** – Express middleware (error handling)
* **controllers/** – Route controllers
* **routes/** – API route definitions
* **services/** – Business logic / service layer
* **utils/** – Helper functions
* **types/** – TypeScript type definitions
* **schemas/** – Mongoose schemas / database models
* **dist/** – Compiled JavaScript (after `npm run build`)
* **.vscode/** – Launch configuration for debugging

---

## Installation

1. **Clone the repository** or download the ZIP:

```bash
git clone https://github.com/mohamede322/express-ts-setup.git
cd express-ts-setup
```

2. **Run the setup script** (recommended way to initialize project with latest version):

```powershell
# Get latest commit SHA
$latestSHA = (Invoke-RestMethod "https://api.github.com/repos/mohamede322/express-ts-setup/commits/main").sha

# Download and run the latest script using that SHA
iwr "https://cdn.jsdelivr.net/gh/mohamede322/express-ts-setup@$latestSHA/setup-express-ts.ps1" | iex
```

This will:

* Create the project folder structure
* Initialize npm and install dependencies
* Set up TypeScript, ESLint, Prettier
* Generate `.env`, `.gitignore`, `README.md`
* Add VS Code launch configuration
* Initialize a Git repository

---

## Scripts

| Command         | Description                       |
| --------------- | --------------------------------- |
| `npm run dev`   | Start development server with TS  |
| `npm run build` | Compile TypeScript to JS          |
| `npm start`     | Run compiled JavaScript from dist |

---

## Environment Variables

Create a `.env` file in the project root with the following:

```env
PORT=3000
DB_URL=mongodb://localhost:27017/testdb
```

* **PORT** – The server port (default: 3000)
* **DB_URL** – MongoDB connection string

---

## Dependencies

* **Runtime:** `express`, `mongoose`, `cors`, `helmet`, `morgan`, `dotenv`
* **Dev:** `typescript`, `ts-node`, `nodemon`, `@types/*`, `eslint`, `prettier`, `@typescript-eslint/*`

---

## ESLint + Prettier

Configured for TypeScript:

* `.eslintrc.json` with recommended rules
* `.prettierrc` for formatting

Run:

```bash
npx eslint 'src/**/*.ts' --fix
```

to auto-fix code style issues.

---

## Debugging in VS Code

The project includes a `.vscode/launch.json` for debugging TypeScript:

* Debug configuration: `Debug TS`
* Pre-launch task: `tsc: build - tsconfig.json`
* Out files: `dist/**/*.js`

Start debugging with **F5** in VS Code.

---

## Contributing / Updating

To always use the latest setup script:

```powershell
# Fetch the latest commit SHA from GitHub
$latestSHA = (Invoke-RestMethod "https://api.github.com/repos/mohamede322/express-ts-setup/commits/main").sha

# Download and run the latest PowerShell setup script
iwr "https://cdn.jsdelivr.net/gh/mohamede322/express-ts-setup@$latestSHA/setup-express-ts.ps1" | iex
```

This ensures you always have the **latest project structure and scripts**.

---

## License

MIT License. Free to use and modify.

---

*Generated with Essam's PowerShell setup script.*
