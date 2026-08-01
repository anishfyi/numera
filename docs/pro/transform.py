"""Turn a NumeraAI marketing page into a static page for numera.velofy.co/pro.

Reads HTML on stdin, writes the transformed HTML on stdout.

    python3 transform.py <index|about> <css_path> <console_url>

Kept as a real file rather than a heredoc inside the shell script: `python3 - <<EOF`
makes the heredoc stdin, which swallows the piped HTML instead of transforming it.
That bug produced a 4KB page from a 19KB source and looked like a truncation.
"""
import re
import sys

html = sys.stdin.read()
page, css_path, console = sys.argv[1], sys.argv[2], sys.argv[3]

# A per-session CSRF token is meaningless in a static page and must not ship.
html = re.sub(r'window\.CSRF\s*=\s*"[^"]*";', 'window.CSRF = "";', html)
html = re.sub(r'<input[^>]*name="csrfmiddlewaretoken"[^>]*>', '', html)

# Stylesheet and any other static asset point at the local copy.
html = html.replace('href="%s"' % css_path, 'href="static/css/numera2.css"')
html = re.sub(r'(href|src)="/static/', r'\1="static/', html)

# App routes do not exist on a static site. Anything needing the running product
# goes to the review console; the two marketing pages point at each other.
for route in ('/accounts/login/', '/accounts/signup/', '/chat/', '/audit/', '/connections/'):
    html = html.replace('href="%s"' % route, 'href="%s"' % console)

html = html.replace('href="/about#', 'href="about.html#')
html = html.replace('href="/about"', 'href="about.html"')
if page == 'about':
    html = html.replace('href="about.html#', 'href="#')
    html = html.replace('href="about.html"', 'href="index.html"')
    html = html.replace('href="/"', 'href="index.html"')
else:
    html = html.replace('href="/"', 'href="#top"')

# "Sign in" and "close your first book free" imply open signup. The console is
# gated and read-only, so the labels say what actually happens.
html = re.sub(r'>\s*Sign in\s*(<span[^>]*>.*?</span>)?\s*</a>',
              lambda m: '>Investor Access %s</a>' % (m.group(1) or ''), html, flags=re.S)
html = re.sub(r'>\s*Close your first book free\s*(<span[^>]*>.*?</span>)?\s*</a>',
              lambda m: '>Open the review console %s</a>' % (m.group(1) or ''), html, flags=re.S)

# Canonical and favicon for the public location, not the container host.
html = re.sub(r'<link rel="canonical"[^>]*>', '', html)
suffix = '' if page == 'index' else 'about.html'
html = html.replace(
    '</head>',
    '<link rel="canonical" href="https://numera.velofy.co/pro/%s">\n'
    '<link rel="icon" href="../favicon.svg" type="image/svg+xml">\n</head>' % suffix,
    1,
)

sys.stdout.write(html)
