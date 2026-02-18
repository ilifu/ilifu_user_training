# Introduction to Slurm - Presentation

This directory contains the Reveal.js presentation for **Session 1, Tutorial 2: Introduction to Slurm**. It covers the basics of job submission, cluster architecture, and best practices.

## Running Locally

To view the presentation, you need to serve the directory over HTTP. Opening `index.html` directly in your browser will not work correctly due to security restrictions on loading local files.

### Method 1: Python (Recommended)

If you have Python 3 installed (which is standard on most Linux/macOS systems):

```bash
# Run from within this directory
python3 -m http.server 8000
```

Then open [http://localhost:8000](http://localhost:8000) in your browser.

### Method 2: Node.js

If you have Node.js installed, you can use `http-server`:

```bash
npx http-server . -p 8000
```

### Method 3: VS Code Live Server

If you use VS Code:
1. Install the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension.
2. Open `index.html`.
3. Click "Go Live" in the bottom-right status bar.

## Project Structure

- **`index.html`**: The main presentation file containing all slides and content.
- **`assets/`**: Images and static resources (logos, diagrams).
- **`demos/`**: Recorded terminal sessions (asciinema casts) and videos.
- **`resources/`**: external CSS/JS libraries (e.g., asciinema player).

## Editing the Presentation

The presentation is built with [Reveal.js](https://revealjs.com/). Everything is contained within `index.html`.

- **Slides**: Each `<section>` tag represents a slide. Nested `<section>` tags create vertical slides.
- **Speaker Notes**: Add `<aside class="notes">...</aside>` inside a slide section. Press `s` during the presentation to view them.
- **Code Blocks**: Use `<pre><code class="language-bash">...</code></pre>` for syntax highlighting.