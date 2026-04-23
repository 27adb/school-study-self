const fs = require('fs')
const path = require('path')

// 使用 canvas 库转换 SVG 到 PNG
// 首先安装：npm install canvas --save-dev

const tabDir = path.join(__dirname, 'src', 'static', 'tab')

const icons = [
  { svg: 'home.svg', png: 'home.png' },
  { svg: 'home-active.svg', png: 'home-active.png' },
  { svg: 'reserve.svg', png: 'reserve.png' },
  { svg: 'reserve-active.svg', png: 'reserve-active.png' },
  { svg: 'user.svg', png: 'user.png' },
  { svg: 'user-active.svg', png: 'user-active.png' }
]

console.log('📋 图标转换工具')
console.log('================\n')

// 检查是否安装了 canvas
let canvas
try {
  const { createCanvas } = require('canvas')
  canvas = createCanvas(162, 162)
  console.log('✅ canvas 库已安装\n')
} catch (e) {
  console.log('❌ canvas 库未安装')
  console.log('\n请运行以下命令安装：')
  console.log('npm install canvas --save-dev\n')
  console.log('或者使用在线工具转换：')
  console.log('https://cloudconvert.com/svg-to-png')
  console.log('https://svgtopng.com/\n')
  process.exit(1)
}

const { createCanvas, loadImage } = require('canvas')

async function convertIcon(icon) {
  const svgPath = path.join(tabDir, icon.svg)
  const pngPath = path.join(tabDir, icon.png)
  
  if (!fs.existsSync(svgPath)) {
    console.log(`⚠️  跳过：${icon.svg} (文件不存在)`)
    return
  }
  
  const svgContent = fs.readFileSync(svgPath, 'utf-8')
  const svgBuffer = Buffer.from(svgContent)
  
  const img = await loadImage(svgBuffer)
  const canvas = createCanvas(162, 162)
  const ctx = canvas.getContext('2d')
  
  ctx.drawImage(img, 0, 0, 162, 162)
  
  const buffer = canvas.toBuffer('image/png')
  fs.writeFileSync(pngPath, buffer)
  
  console.log(`✅ 转换成功：${icon.svg} -> ${icon.png} (162x162)`)
}

async function main() {
  console.log('开始转换图标...\n')
  
  for (const icon of icons) {
    await convertIcon(icon)
  }
  
  console.log('\n✨ 所有图标转换完成！')
  console.log('\n提示：图标文件已保存到 src/static/tab/ 目录')
}

main().catch(console.error)
