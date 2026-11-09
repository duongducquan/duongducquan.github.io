// ---- Theme toggle ----
const themeToggle = document.getElementById('themeToggle');
const root = document.documentElement;

function applyTheme(theme){
  if(theme === 'dark'){
    root.setAttribute('data-theme','dark');
    themeToggle.innerHTML = '<i class="fa-solid fa-sun"></i>';
  } else {
    root.removeAttribute('data-theme');
    themeToggle.innerHTML = '<i class="fa-solid fa-moon"></i>';
  }
}

const savedTheme = localStorage.getItem('ngan_theme') || 'light';
applyTheme(savedTheme);

themeToggle.addEventListener('click', () => {
  const current = root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
  const next = current === 'dark' ? 'light' : 'dark';
  applyTheme(next);
  localStorage.setItem('ngan_theme', next);
});

// ---- Copy to clipboard ----
const toast = document.getElementById('copyToast');
let toastTimer = null;

function showToast(msg){
  toast.textContent = msg;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 1800);
}

document.querySelectorAll('.copy-btn').forEach(btn => {
  btn.addEventListener('click', async (e) => {
    e.preventDefault();
    const text = btn.getAttribute('data-copy');
    try{
      await navigator.clipboard.writeText(text);
      showToast('Đã sao chép: ' + text);
    }catch(err){
      // fallback
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      showToast('Đã sao chép: ' + text);
    }
  });
});


