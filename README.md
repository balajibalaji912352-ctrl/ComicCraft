# ComicCraft — AI Comic Story Creator

ComicCraft is a FastAPI + Jinja2 web application that turns a user's story idea into a five-panel comic. It follows the supplied project documentation: a structured panel outline is generated first, a second Gemini step expands it into narration/dialogue, Stable Diffusion creates an illustration for each panel, the layout is assembled, and FPDF exports the result as a PDF.

## Project structure

```text
ComicCraft/
├── app/
│   ├── main.py
│   ├── routes.py
│   ├── config.py
│   ├── schemas.py
│   ├── services/
│   │   ├── comic_service.py
│   │   ├── gemini_flash.py
│   │   ├── gemini_pro.py
│   │   ├── image_generator.py
│   │   ├── layout_builder.py
│   │   └── exporters.py
│   ├── templates/
│   │   ├── index.html
│   │   ├── comic_preview.html
│   │   └── export_success.html
│   └── static/
│       ├── css/styles.css
│       ├── js/app.js
│       ├── panels/
│       └── exports/
├── tests/test_app.py
├── .env.example
├── requirements.txt
├── run.bat
├── run.sh
└── README.md
```

## 1. VS Code setup (Windows)

1. Install Python 3.11 or 3.12 and VS Code.
2. Open **File → Open Folder** in VS Code and select the `ComicCraft` folder.
3. Open **Terminal → New Terminal**.
4. Create a virtual environment:

```powershell
python -m venv .venv
```

5. Activate it:

```powershell
.venv\Scripts\activate
```

6. Select the interpreter in VS Code: press `Ctrl+Shift+P` → **Python: Select Interpreter** → choose `.venv`.
7. Upgrade pip and install dependencies:

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

> `torch`, `diffusers`, and the Stable Diffusion model are large. The application uses lazy model loading, so the web server can start before the model is downloaded.

## 2. Quick start in demo mode

Demo mode is the easiest way to prove that the frontend, backend, API, layout builder, image files, and PDF exporter all work together without an API key or GPU.

Copy the example environment file:

```powershell
copy .env.example .env
```

Edit `.env` and set:

```env
DEMO_MODE=true
IMAGE_BACKEND=demo
```

Run:

```powershell
uvicorn app.main:app --reload
```

Open:

- App: `http://127.0.0.1:8000`
- FastAPI docs: `http://127.0.0.1:8000/docs`
- Health check: `http://127.0.0.1:8000/health`

## 3. Enable real Gemini generation

Create a Gemini API key in Google AI Studio, then edit `.env`:

```env
DEMO_MODE=false
GEMINI_API_KEY=your_real_key_here
GEMINI_OUTLINE_MODEL=gemini-2.5-flash
GEMINI_STORY_MODEL=gemini-2.5-pro
```

The model names are environment variables intentionally. The original PDF refers to Gemini 1.5 Flash/Pro, but model availability changes over time. If Google AI Studio shows different models for your account, replace the two model IDs in `.env` without changing the code.

## 4. Enable Stable Diffusion images

Set:

```env
IMAGE_BACKEND=diffusers
STABLE_DIFFUSION_MODEL=stable-diffusion-v1-5/stable-diffusion-v1-5
HF_API_KEY=
```

The first real image generation downloads the model from Hugging Face. A CUDA-capable NVIDIA GPU is strongly recommended. CPU generation can be very slow.

If the model requires authentication on your machine, add your Hugging Face token to `HF_API_KEY`.

## 5. Run the application

```powershell
uvicorn app.main:app --reload
```

Then visit `http://127.0.0.1:8000`.

### Main endpoints

- `GET /` — homepage
- `POST /generate` — HTML form comic generation
- `POST /generate-comic/json` — JSON API comic generation
- `GET /test-image?prompt=...` — image generation test
- `GET /export-success` — export confirmation page
- `GET /health` — app health check
- `GET /docs` — Swagger/OpenAPI interface

## 6. Test the JSON API

From `http://127.0.0.1:8000/docs`, open `POST /generate-comic/json` and use:

```json
{
  "story_prompt": "A brave fox discovers a hidden library in an enchanted forest.",
  "character_name": "Fia",
  "setting": "enchanted forest",
  "tone": "adventurous",
  "art_style": "classic comic book"
}
```

The response contains the five-panel `layout`, local image paths/URLs, and the exported PDF path/URL.

## 7. Run automated tests

Use demo mode for fast tests:

```powershell
$env:DEMO_MODE="true"
$env:IMAGE_BACKEND="demo"
pytest -q
```

The tests check the homepage, health endpoint, complete five-panel JSON generation flow, panel image creation, and PDF creation.

## 8. Common issues

### `GEMINI_API_KEY` missing
The app automatically falls back to demo mode if no Gemini key is configured. Add the key to `.env` and restart Uvicorn to use real Gemini calls.

### Gemini model not available
Change `GEMINI_OUTLINE_MODEL` or `GEMINI_STORY_MODEL` in `.env` to a model available to your Google AI Studio account.

### Stable Diffusion is too slow / out of memory
Use `IMAGE_BACKEND=demo` while developing the rest of the app. For real generation, a GPU is recommended. You can also reduce `IMAGE_WIDTH`, `IMAGE_HEIGHT`, or `IMAGE_STEPS` in `.env`.

### Port 8000 already in use
Run on another port:

```powershell
uvicorn app.main:app --reload --port 8001
```

## Notes on the supplied documentation

The implementation follows the documented architecture and workflow but modernizes the Gemini Python integration to the current `google-genai` SDK. It also adds Pydantic validation, centralized configuration, explicit error handling, lazy Stable Diffusion loading, automated tests, and a demo mode so the project can be tested end-to-end on ordinary development machines.
