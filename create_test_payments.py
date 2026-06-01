"""
Script para crear datos de prueba de Pagos de Taller
en el backend para probar el modulo de Pagos en la app movil.

Uso:
  python create_test_payments.py <email> <password>
"""
import sys
import os
import requests
import json

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
    tokens = data.get("tokens", {})
    token = tokens.get("access") or data.get("token") or data.get("access")
    empresa_id = data.get("tenant", {}).get("id") or data.get("usuario", {}).get("empresa_id")
    if not token:
        print(f"No token found: {json.dumps(data, indent=2)}")
        sys.exit(1)
    print(f"✅ Login exitoso. Empresa: {empresa_id}")
    return token, empresa_id

def headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

def get_ventas(token):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/ventas-mostrador/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    return results if isinstance(results, list) else []

def get_citas(token):
    url = f"{BASE_URL}/api/{SLUG}/vehiculos-servicios/citas/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    return results if isinstance(results, list) else []

def get_pagos(token):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/pagos-taller/"
    resp = requests.get(url, headers=headers(token))
    if resp.status_code != 200:
        print(f"ERROR pagos: {resp.status_code} - {resp.text}")
        return []
    data = resp.json()
    results = data.get("results", data) if isinstance(data, dict) else data
    return results if isinstance(results, list) else []

def crear_pago(token, payload):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/pagos-taller/"
    resp = requests.post(url, headers=headers(token), json=payload)
    if resp.status_code in (200, 201):
        data = resp.json()
        print(f"  ✅ Pago creado: {data.get('id', 'N/A')[:8]}... Estado: {data.get('estado')} | Metodo: {data.get('metodo_pago')} | Total: {data.get('monto_total')}")
        return data
    else:
        print(f"  ERROR crear pago: {resp.status_code} - {resp.text[:200]}")
        return None

def marcar_recibido(token, pago_id):
    url = f"{BASE_URL}/api/{SLUG}/gestion-administrativa/pagos-taller/{pago_id}/marcar-recibido/"
    resp = requests.post(url, headers=headers(token))
    if resp.status_code == 200:
        print(f"  ✅ Pago {pago_id[:8]}... MARCADO COMO RECIBIDO")
        return resp.json()
    else:
        print(f"  ERROR marcar recibido: {resp.status_code} - {resp.text[:200]}")
        return None

def main():
    if len(sys.argv) < 3:
        print("Uso: python create_test_payments.py <email> <password>")
        sys.exit(1)

    email = sys.argv[1]
    password = sys.argv[2]

    print("=" * 60)
    print("  Creador de datos de prueba - Pagos de Taller")
    print("=" * 60)
    print()

    token, empresa_id = login(email, password)
    print()

    # Get existing ventas and citas for linking
    print("📋 Buscando ventas existentes...")
    ventas = get_ventas(token)
    print(f"   Encontradas {len(ventas)} ventas.")
    for v in ventas[:3]:
        print(f"   - {v.get('id', 'N/A')[:8]}... Estado: {v.get('estado')} | Total: {v.get('total')}")

    print()
    print("📋 Buscando citas existentes...")
    citas = get_citas(token)
    print(f"   Encontradas {len(citas)} citas.")
    for c in citas[:3]:
        print(f"   - {c.get('id', 'N/A')[:8]}... Estado: {c.get('estado')}")

    print()
    print("🔍 Verificando pagos existentes...")
    pagos_existentes = get_pagos(token)
    print(f"   Actualmente hay {len(pagos_existentes)} pagos.")
    print()

    venta_id = ventas[0]["id"] if ventas else None
    cita_id = citas[0]["id"] if citas else None

    # Pago 1: PENDIENTE - Efectivo - de una venta
    print("💰 Creando Pago 1 (PENDIENTE - Efectivo - Venta)...")
    p1_data = {
        "empresa": empresa_id,
        "tipo_origen": "VENTA",
        "tipo_destino": "VENTA",
        "id_destino": str(venta_id) if venta_id else "TEST-001",
        "estado": "PENDIENTE",
        "monto_total": "150.00",
        "monto_real": "150.00",
        "monto_cobrado": "150.00",
        "metodo_pago": "EFECTIVO",
        "moneda": "BOB",
        "descripcion": "Pago en efectivo - cambio de frenos",
    }
    if venta_id:
        p1_data["venta"] = venta_id
    p1 = crear_pago(token, p1_data)

    # Pago 2: PENDIENTE - Tarjeta - de una cita
    print("\n💰 Creando Pago 2 (PENDIENTE - Tarjeta - Cita)...")
    p2_data = {
        "empresa": empresa_id,
        "tipo_origen": "CITA",
        "tipo_destino": "CITA",
        "id_destino": str(cita_id) if cita_id else "TEST-002",
        "estado": "PENDIENTE",
        "monto_total": "350.00",
        "monto_real": "350.00",
        "monto_cobrado": "350.00",
        "metodo_pago": "TARJETA",
        "moneda": "BOB",
        "descripcion": "Pago con tarjeta - servicio completo",
    }
    if cita_id:
        p2_data["cita"] = cita_id
    p2 = crear_pago(token, p2_data)

    # Pago 3: PENDIENTE - QR
    print("\n💰 Creando Pago 3 (PENDIENTE - QR)...")
    p3_data = {
        "empresa": empresa_id,
        "tipo_origen": "VENTA",
        "tipo_destino": "VENTA",
        "id_destino": str(venta_id) if venta_id else "TEST-003",
        "estado": "PENDIENTE",
        "monto_total": "85.50",
        "monto_real": "85.50",
        "monto_cobrado": "85.50",
        "metodo_pago": "QR",
        "moneda": "BOB",
        "descripcion": "Pago QR - compra de lubricantes",
    }
    if venta_id:
        p3_data["venta"] = venta_id
    p3 = crear_pago(token, p3_data)

    # Pago 4: CONFIRMADO (marcar recibido)
    print("\n💰 Creando Pago 4 (PENDIENTE -> CONFIRMADO)...")
    p4_data = {
        "empresa": empresa_id,
        "tipo_origen": "CITA",
        "tipo_destino": "CITA",
        "id_destino": str(cita_id) if cita_id else "TEST-004",
        "estado": "PENDIENTE",
        "monto_total": "500.00",
        "monto_real": "500.00",
        "monto_cobrado": "500.00",
        "metodo_pago": "EFECTIVO",
        "moneda": "BOB",
        "descripcion": "Pago efectivo - mantenimiento general",
    }
    if cita_id:
        p4_data["cita"] = cita_id
    p4 = crear_pago(token, p4_data)
    if p4:
        marcar_recibido(token, p4["id"])

    # Pago 5: PENDIENTE - high amount
    print("\n💰 Creando Pago 5 (PENDIENTE - Efectivo - alto monto)...")
    p5_data = {
        "empresa": empresa_id,
        "tipo_origen": "VENTA",
        "tipo_destino": "VENTA",
        "id_destino": "MOSTRADOR-PREMIUM",
        "estado": "PENDIENTE",
        "monto_total": "1250.00",
        "monto_real": "1250.00",
        "monto_cobrado": "1250.00",
        "metodo_pago": "EFECTIVO",
        "moneda": "BOB",
        "descripcion": "Pago efectivo - set completo de llantas premium",
    }
    crear_pago(token, p5_data)

    print()
    print("=" * 60)
    print("  ✅ Datos de prueba de pagos creados exitosamente!")
    print("  📱 Abre la app movil > Pagos de Taller")
    print("     para ver los pagos en diferentes estados.")
    print("  ℹ️  4 pagos PENDIENTES (para probar 'Marcar Recibido')")
    print("  ℹ️  1 pago CONFIRMADO (ya recibido)")
    print("=" * 60)

if __name__ == "__main__":
    main()
