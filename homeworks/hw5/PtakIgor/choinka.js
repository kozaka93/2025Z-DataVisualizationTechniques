window.onload = function () {
  const canvas = document.getElementById("treeCanvas");
  const ctx = canvas.getContext("2d");
  const drawBtn = document.getElementById("drawBtn");
  const saveBtn = document.getElementById("saveBtn");

  function generateTree() {
    const rule = parseInt(document.getElementById("rule").value) || 30;
    const heightInput =
      parseInt(document.getElementById("height").value) || 600;
    const seedInput = parseInt(document.getElementById("seed").value) || 2026;

    let seed = seedInput;
    function random() {
      seed = (seed * 16807) % 2147483647;
      return (seed - 1) / 2147483646;
    }

    canvas.height = heightInput;
    const width = canvas.width;
    const height = canvas.height;

    const cellSize = 2;
    const trunkHeight = Math.floor(height * 0.1);
    const treeHeight = height - trunkHeight - 40;
    const rows = Math.floor(treeHeight / cellSize);
    const cols = Math.floor(width / cellSize);
    const center = Math.floor(cols / 2);

    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, "#001f3f");
    gradient.addColorStop(1, "#000810");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);

    ctx.fillStyle = "white";
    for (let i = 0; i < 100; i++) {
      ctx.fillRect(random() * width, random() * height, 2, 2);
    }

    const ruleSet = [];
    for (let i = 0; i < 8; i++) ruleSet[i] = (rule >> i) & 1;

    let currentGeneration = new Array(cols).fill(0);
    currentGeneration[center] = 1;

    const startY = 40;

    for (let t = 0; t < rows; t++) {
      const treeWidth = Math.floor((t / rows) * (cols * 0.255));

      for (let i = 0; i < cols; i++) {
        const distFromCenter = Math.abs(i - center);

        if (distFromCenter <= treeWidth) {
          if (currentGeneration[i] === 1) {
            ctx.fillStyle = "green";
            if (random() > 0.97) {
              ctx.fillStyle = ["red", "yellow", "#7FDBFF"][
                Math.floor(random() * 3)
              ];
              ctx.beginPath();
              ctx.arc(i * cellSize, startY + t * cellSize, 3, 0, Math.PI * 2);
              ctx.fill();
            } else {
              ctx.fillRect(
                i * cellSize,
                startY + t * cellSize,
                cellSize,
                cellSize
              );
            }
          }
        }
      }

      const nextGeneration = new Array(cols).fill(0);
      for (let i = 1; i < cols - 1; i++) {
        const index =
          (currentGeneration[i - 1] << 2) |
          (currentGeneration[i] << 1) |
          currentGeneration[i + 1];
        nextGeneration[i] = ruleSet[index];
      }
      currentGeneration = nextGeneration;
    }

    const trunkWidth = 30;
    ctx.fillStyle = "#5b1500ff";
    ctx.fillRect(
      width / 2 - trunkWidth / 2,
      startY + rows * cellSize,
      trunkWidth,
      trunkHeight
    );

    drawStar(width / 2, startY, 5, 12, 6);

    ctx.fillStyle = "rgba(255,255,255,0.7)";
  }

  function drawStar(cx, cy, spikes, outerRadius, innerRadius) {
    let rot = (Math.PI / 2) * 3;
    let x = cx;
    let y = cy;
    let step = Math.PI / spikes;

    ctx.beginPath();
    ctx.moveTo(cx, cy - outerRadius);
    for (let i = 0; i < spikes; i++) {
      x = cx + Math.cos(rot) * outerRadius;
      y = cy + Math.sin(rot) * outerRadius;
      ctx.lineTo(x, y);
      rot += step;

      x = cx + Math.cos(rot) * innerRadius;
      y = cy + Math.sin(rot) * innerRadius;
      ctx.lineTo(x, y);
      rot += step;
    }
    ctx.lineTo(cx, cy - outerRadius);
    ctx.closePath();
    ctx.fillStyle = "yellow";
    ctx.fill();
  }

  drawBtn.addEventListener("click", generateTree);

  saveBtn.addEventListener("click", function () {
    const link = document.createElement("a");
    link.download = "choinka.png";
    link.href = canvas.toDataURL();
    link.click();
  });

  generateTree();
};
