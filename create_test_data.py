"""
Script para crear datos de prueba de Solicitudes de Repuesto
en el backend para probar el flujo de Abastecimiento por Faltante
en la app móvil.

Uso:
  python create_test_data.py <email> <password>
"""
import sys
import os
import requests
import json

# Fix Windows console encoding
if sys.platform == "win32":
    os.environ["PYTHONIOENCODING"] = "utf-8"
    sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "https://backendautomotriz.onrender.com"
SLUG = "transformers"

def login(email, password):
    url = f"{BASE_URL}/api/tenants/{SLUG}/auth/login/"
    resp = requests.post(url, json={"email": email, "password": password})
    if resp.status_code != 200:
        print(f"ERROR login: {resp.status_code} - {resp.text}")
        sys.exit(1)
    data = resp.json()
    # Try different token locations
    token = data.get("token") or data.get("access") or data.get("key")
    if not token:
        # Nested tokens object (JWT)
        tokens = data.get("tokens", {})
        token = tokens.get("access") or tokens.get("token")
    if not token:
        token = data.get("data", {}).get("token") or data.get("data", {}).get("access")
    if not token:
        print(f"No se encontró token en la respuesta: {json.dumps(data, indent=2)}")
        sys.exit(1)
    print(f"✅ Login exitoso. Token: {token[:20]}...")
    return token

def headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

def get_citas(token):
    url = f"{BASE_URL}/api/{SLUG}/vehiculos-servicios/citas/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        print(f"ERROR citas: {resp.status_code} - {resp.text}")
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    if isinstance(results, list):
        return results
    return []

def get_items_inventario(token):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/items-inventario/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        print(f"ERROR items: {resp.status_code} - {resp.text}")
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    if isinstance(results, list):
        return results
    return []

def get_solicitudes(token):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/solicitudes-repuesto/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        print(f"ERROR solicitudes: {resp.status_code} - {resp.text}")
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    if isinstance(results, list):
        return results
    return []

def crear_solicitud(token, cita_id, detalles, motivo="Faltante detectado en inspección"):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/solicitudes-repuesto/"
    payload = {
        "cita_id": cita_id,
        "motivo": motivo,
        "detalles": detalles,
    }
    resp = requests.post(url, headers=headers(token), json=payload)
    if resp.status_code in (200, 201):
        data = resp.json()
        print(f"✅ Solicitud creada: {data.get('id', 'N/A')[:8]}... Estado: {data.get('estado')}")
        return data
    else:
        print(f"ERROR crear solicitud: {resp.status_code} - {resp.text}")
        return None

def aprobar_solicitud(token, solicitud_id):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/solicitudes-repuesto/{solicitud_id}/aprobar/"
    resp = requests.post(url, headers=headers(token), json={"observaciones_asesor": "Aprobada - repuestos necesarios"})
    if resp.status_code == 200:
        print(f"✅ Solicitud {solicitud_id[:8]}... APROBADA")
        return resp.json()
    else:
        print(f"ERROR aprobar: {resp.status_code} - {resp.text}")
        return None

def en_proceso_almacen(token, solicitud_id):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/solicitudes-repuesto/{solicitud_id}/en-proceso-almacen/"
    resp = requests.post(url, headers=headers(token), json={"observaciones_almacen": "Preparando repuestos"})
    if resp.status_code == 200:
        print(f"✅ Solicitud {solicitud_id[:8]}... EN REVISION ALMACEN")
        return resp.json()
    else:
        print(f"ERROR en-proceso: {resp.status_code} - {resp.text}")
        return None

def marcar_entregada(token, solicitud_id, detalles_entrega):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/solicitudes-repuesto/{solicitud_id}/marcar-entregada/"
    resp = requests.post(url, headers=headers(token), json={"detalles": detalles_entrega})
    if resp.status_code == 200:
        print(f"✅ Solicitud {solicitud_id[:8]}... ENTREGADA")
        return resp.json()
    else:
        print(f"ERROR entregar: {resp.status_code} - {resp.text}")
        return None

def main():
    if len(sys.argv) < 3:
        print("Uso: python create_test_data.py <email> <password>")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]

    print("=" * 60)
    print("  Creador de datos de prueba - Abastecimiento por Faltante")
    print("=" * 60)
    print()

    # 1. Login
    token = login(email, password)
    print()

    # 2. Listar citas existentes
    print("📋 Buscando citas existentes...")
    citas = get_citas(token)
    if not citas:
        print("⚠️  No hay citas. Se necesita al menos una cita para crear solicitudes.")
        print("   Crea una cita primero desde la app web o móvil.")
        sys.exit(1)
    
    print(f"   Encontradas {len(citas)} citas.")
    for c in citas[:5]:
        print(f"   - {c.get('id', 'N/A')[:8]}... Estado: {c.get('estado', 'N/A')} | Fecha: {c.get('fecha_hora', c.get('fecha', 'N/A'))}")
    cita_id = citas[0]["id"]
    print(f"   ➡️  Usando cita: {cita_id[:8]}...")
    print()

    # 3. Listar items de inventario
    print("📦 Buscando items de inventario...")
    items = get_items_inventario(token)
    if not items:
        print("⚠️  No hay items de inventario.")
        print("   Crea items desde el módulo de Inventario en la app web o móvil.")
        sys.exit(1)

    print(f"   Encontrados {len(items)} items.")
    for it in items[:8]:
        print(f"   - {it.get('id', 'N/A')[:8]}... {it.get('nombre', 'N/A')} | Stock: {it.get('stock_actual', 'N/A')}")
    print()

    # 4. Verificar solicitudes existentes
    print("🔍 Verificando solicitudes existentes...")
    solicitudes = get_solicitudes(token)
    print(f"   Actualmente hay {len(solicitudes)} solicitudes.")
    for s in solicitudes[:5]:
        print(f"   - {s.get('id', 'N/A')[:8]}... Estado: {s.get('estado', 'N/A')} | Detalles: {len(s.get('detalles', []))}")
    print()

    # 5. Crear solicitudes de prueba en diferentes estados
    items_para_solicitar = items[:min(3, len(items))]

    # Solicitud 1: Estado CREADA (recién creada)
    print("📝 Creando Solicitud 1 (estado CREADA)...")
    detalles1 = [{"item_inventario_id": items_para_solicitar[0]["id"], "cantidad_solicitada": 2, "observacion": "Urgente - frenos desgastados"}]
    if len(items_para_solicitar) > 1:
        detalles1.append({"item_inventario_id": items_para_solicitar[1]["id"], "cantidad_solicitada": 1, "observacion": "Reemplazo preventivo"})
    s1 = crear_solicitud(token, cita_id, detalles1, "Faltante detectado: frenos y filtro")

    # Solicitud 2: Estado APROBADA_POR_ASESOR
    print("\n📝 Creando Solicitud 2 (estado APROBADA)...")
    detalles2 = [{"item_inventario_id": items_para_solicitar[0]["id"], "cantidad_solicitada": 3, "observacion": "Cambio de aceite completo"}]
    s2 = crear_solicitud(token, cita_id, detalles2, "Mantenimiento programado - aceite")
    if s2:
        aprobar_solicitud(token, s2["id"])

    # Solicitud 3: Estado EN_REVISION_ALMACEN
    if len(items_para_solicitar) > 1:
        print("\n📝 Creando Solicitud 3 (estado EN REVISION ALMACEN)...")
        detalles3 = [
            {"item_inventario_id": items_para_solicitar[0]["id"], "cantidad_solicitada": 1, "observacion": "Pastillas de freno"},
            {"item_inventario_id": items_para_solicitar[1]["id"], "cantidad_solicitada": 2, "observacion": "Filtros aire"},
        ]
        s3 = crear_solicitud(token, cita_id, detalles3, "Revisión completa - frenos y filtros")
        if s3:
            aprobar_solicitud(token, s3["id"])
            en_proceso_almacen(token, s3["id"])

    # Solicitud 4: Estado ENTREGADA (lista para "Recibir en Taller")
    if len(items_para_solicitar) > 0:
        print("\n📝 Creando Solicitud 4 (estado ENTREGADA - para probar Recibir en Taller)...")
        detalles4 = [{"item_inventario_id": items_para_solicitar[0]["id"], "cantidad_solicitada": 1, "observacion": "Repuesto urgente"}]
        s4 = crear_solicitud(token, cita_id, detalles4, "Repuesto urgente para entrega inmediata")
        if s4:
            aprobar_solicitud(token, s4["id"])
            en_proceso_almacen(token, s4["id"])
            # Marcar entrega
            detalles_entrega = [{"detalle_id": d["id"], "cantidad_entregada": d["cantidad_solicitada"]} for d in s4.get("detalles", [])]
            if detalles_entrega:
                # Need to re-fetch to get updated detalles after approve/en-proceso
                solicitudes_updated = get_solicitudes(token)
                for su in solicitudes_updated:
                    if su["id"] == s4["id"]:
                        detalles_entrega = [{"detalle_id": d["id"], "cantidad_entregada": d["cantidad_solicitada"]} for d in su.get("detalles", [])]
                        marcar_entregada(token, s4["id"], detalles_entrega)
                        break

    print()
    print("=" * 60)
    print("  ✅ Datos de prueba creados exitosamente!")
    print("  📱 Abre la app móvil > Abastecimiento por Faltante")
    print("     para ver las solicitudes en diferentes estados.")
    print("=" * 60)

if __name__ == "__main__":
    main()
