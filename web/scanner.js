// DrawPets' swap-code scanner for the web version: the camera over the game until it reads a QR
// code, or the kid taps Back. The Android app has its own (ZXing, in the DrawPetsNearby plugin);
// a browser has the camera and jsQR - a plain pattern decoder, no AI - instead.
//
// The game (SwapScreen) calls window.drawpetsScanner.start(prompt, onCode, onClose) through
// JavaScriptBridge. Nothing the camera sees is kept or sent anywhere: each frame is looked at for
// a code and dropped. Copied next to the export by tools/release/release.sh (and the web build).
;(function () {
  'use strict'
  const PAPER = '#f6f1e4'
  const INK = '#3b3566'
  const ACCENT = '#ff8a5c'
  let overlay = null
  let stream = null
  let running = false
  let jsqrLoading = null

  function loadJsQR() {
    if (window.jsQR) return Promise.resolve()
    if (!jsqrLoading) {
      jsqrLoading = new Promise((resolve, reject) => {
        const s = document.createElement('script')
        s.src = 'jsQR.js'
        s.onload = resolve
        s.onerror = reject
        document.head.appendChild(s)
      })
    }
    return jsqrLoading
  }

  function close() {
    running = false
    if (stream) stream.getTracks().forEach((t) => t.stop())
    stream = null
    if (overlay) overlay.remove()
    overlay = null
  }

  function build(prompt, onClose) {
    overlay = document.createElement('div')
    overlay.style.cssText =
      `position:fixed;inset:0;z-index:1000;background:${PAPER};display:flex;flex-direction:column;` +
      `align-items:center;justify-content:center;gap:16px;font-family:system-ui,sans-serif;color:${INK};`
    const title = document.createElement('div')
    title.textContent = prompt
    title.style.cssText = 'font-size:clamp(20px,4vw,34px);font-weight:700;text-align:center;padding:0 16px;'
    const video = document.createElement('video')
    video.setAttribute('playsinline', '')
    video.muted = true
    video.style.cssText =
      `max-width:min(92vw,720px);max-height:62vh;border:6px solid ${INK};border-radius:18px;background:${PAPER};`
    const back = document.createElement('button')
    back.textContent = 'Back'
    back.style.cssText =
      `font-size:24px;font-weight:700;padding:14px 40px;border:4px solid ${INK};border-radius:16px;` +
      `background:${ACCENT};color:${INK};cursor:pointer;`
    back.onclick = () => {
      close()
      onClose('back')
    }
    overlay.append(title, video, back)
    document.body.appendChild(overlay)
    return video
  }

  window.drawpetsScanner = {
    available() {
      return !!(window.isSecureContext && navigator.mediaDevices && navigator.mediaDevices.getUserMedia)
    },

    // onCode(text) once a code is read; onClose(why) if not - "back" or "camera" (refused/none).
    start(prompt, onCode, onClose) {
      if (running) return
      running = true
      const video = build(prompt, onClose)
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d', { willReadFrequently: true })
      Promise.all([
        loadJsQR(),
        navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false }),
      ])
        .then(([, s]) => {
          if (!running) {
            s.getTracks().forEach((t) => t.stop())
            return
          }
          stream = s
          video.srcObject = s
          return video.play()
        })
        .then(() => {
          const look = () => {
            if (!running) return
            if (video.readyState >= 2 && video.videoWidth > 0) {
              // Looked at no bigger than 640 px across: plenty for a code held up close.
              const k = Math.min(1, 640 / video.videoWidth)
              canvas.width = Math.round(video.videoWidth * k)
              canvas.height = Math.round(video.videoHeight * k)
              ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
              const img = ctx.getImageData(0, 0, canvas.width, canvas.height)
              const found = window.jsQR(img.data, img.width, img.height, { inversionAttempts: 'dontInvert' })
              if (found && found.data) {
                close()
                onCode(String(found.data).slice(0, 512))
                return
              }
            }
            requestAnimationFrame(look)
          }
          requestAnimationFrame(look)
        })
        .catch(() => {
          if (!running) return
          close()
          onClose('camera')
        })
    },

    stop: close,
  }
})()
