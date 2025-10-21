(function(){
  const name = document.getElementById('name')
  const address = document.getElementById('address')
  const shellSelect = document.getElementById('shellSelect')
  const price = document.getElementById('price')
  const interact = document.getElementById('interact')
  const entrance = document.getElementById('entrance')
  const exitp = document.getElementById('exit')
  const yard = document.getElementById('yard')
  const status = document.getElementById('status')

  window.addEventListener('message', (ev) => {
    const d = ev.data
    if (d.action === 'open') {
      // noop
    }
    if (d.action === 'loadShells') {
      shellSelect.innerHTML = '<option value="">(none)</option>'
      d.shells.forEach(s => {
        const opt = document.createElement('option')
        opt.value = s.id; opt.textContent = s.label
        shellSelect.appendChild(opt)
      })
    }
    if (d.action === 'pickedCoords' && d.coords) {
      if (!entrance.value) entrance.value = JSON.stringify(d.coords)
      else exitp.value = JSON.stringify(d.coords)
    }
    if (d.action === 'loadProperties' && d.properties) {
      status.textContent = 'Loaded ' + d.properties.length + ' properties'
    }
  })

  document.getElementById('save').onclick = function(){
    const data = {
      name: name.value,
      address: address.value,
      shell: shellSelect.value,
      price: parseInt(price.value) || 0,
      interact_points: interact.value.split(',').map(s=>s.trim()).filter(Boolean),
      entrance: tryParseJSON(entrance.value),
      exit: tryParseJSON(exitp.value),
      yard_zone: tryParseJSON(yard.value)
    }
    fetch(`https://${GetParentResourceName()}/submitProperty`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data)
    }).then(r => r.json()).then(resp => {
      status.textContent = 'Saved (server processing).'
    }).catch(e => status.textContent = 'Error sending to server.')
  }

  document.getElementById('close').onclick = function(){
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' })
  }

  function tryParseJSON(s){ if(!s) return nil; try { return JSON.parse(s) } catch(e) { return s } }
})();
