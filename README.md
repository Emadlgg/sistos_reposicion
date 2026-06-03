# Buffer Overflow — Demostración práctica

Demostración en C de un buffer overflow, sus consecuencias y las mitigaciones que aplican los sistemas operativos modernos: **Stack Canaries**, **ASLR** y **DEP/NX Bit**.

---

## Archivos

| Archivo | Descripción |
|---|---|
| `vulnerable.c` | Programa con buffer overflow usando `strcpy` sin límite |
| `safe.c` | Versión corregida usando `strncpy` con límite explícito |
| `check_aslr.sh` | Script que muestra el efecto de ASLR en las direcciones de memoria |

---

## Requisitos

- Linux (Ubuntu, Debian o cualquier distro moderna)
- GCC
- Python 3

```bash
sudo apt install gcc python3   # si no los tenés instalados
```

---

## Compilación

### `vulnerable` — sin protecciones (para ver el overflow puro)

```bash
gcc -o vulnerable vulnerable.c \
    -fno-stack-protector \
    -z execstack \
    -no-pie \
    -D_FORTIFY_SOURCE=0
```

### `vulnerable_safe` — mismo código, protecciones del compilador activas

```bash
gcc -o vulnerable_safe vulnerable.c
```

### `safe` — código corregido

```bash
gcc -o safe safe.c
```

---

## Demo paso a paso

### 1. Input normal

```bash
./vulnerable "Hola mundo"
```

El programa funciona correctamente. El buffer tiene espacio de sobra.

---

### 2. Overflow leve — pisa el saved RBP

```bash
./vulnerable $(python3 -c "print('A' * 80)")
```

Se escriben 80 bytes en un buffer de 64. Los 16 bytes extras sobrescriben el saved RBP.

---

### 3. Overflow severo — pisa el return address

```bash
./vulnerable $(python3 -c "print('A' * 200)")
```

El return address queda sobrescrito con `0x4141414141` (la letra A en hex). Al retornar la función, el programa salta a una dirección inválida → **Segmentation fault**.

---

### 4. Stack Canary en acción

```bash
./vulnerable_safe $(python3 -c "print('A' * 200)")
```

El compilador insertó un valor aleatorio (canary) entre el buffer y el return address. El overflow lo pisa → el programa detecta la corrupción y aborta con **stack smashing detected** antes de ejecutar código malicioso.

---

### 5. ASLR — direcciones que cambian

```bash
# Verificar que ASLR esté activo (debe decir 2)
cat /proc/sys/kernel/randomize_va_space

# Ver cómo cambian las direcciones en cada ejecución
chmod +x check_aslr.sh
./check_aslr.sh
```

Con ASLR activo las direcciones del stack, heap y librerías cambian en cada ejecución, haciendo impredicible el layout de memoria para un atacante.

---

### 6. Sin ASLR — direcciones fijas

```bash
# Desactivar ASLR
sudo sysctl -w kernel.randomize_va_space=0

# Correr el script de nuevo — las direcciones ya no cambian
./check_aslr.sh

# Reactivar siempre al terminar
sudo sysctl -w kernel.randomize_va_space=2
```

Sin ASLR, las direcciones son siempre las mismas. Un atacante que corra el binario una sola vez ya conoce las direcciones exactas para construir su exploit.

---

## ¿Qué protecciones existen?

### A nivel de compilador / aplicación

| Técnica | Descripción |
|---|---|
| Stack Canaries | Valor centinela entre buffer y return address (`-fstack-protector-strong`) |
| Funciones seguras | `strncpy`, `snprintf`, `fgets` en lugar de `strcpy`, `gets`, `sprintf` |
| Lenguajes memory-safe | Rust, Go — verificación de límites en tiempo de compilación/ejecución |

### A nivel de sistema operativo

| Técnica | Descripción |
|---|---|
| ASLR | Randomiza las direcciones base del stack, heap y librerías en cada ejecución |
| DEP / NX Bit | Marca el stack y heap como no ejecutables — impide correr shellcode inyectado |
| PIE | Position Independent Executable — permite que ASLR aplique también al texto del binario |

---

## Concepto clave: defensa en capas

Ninguna técnica por sí sola es suficiente:

- Los **canaries** se pueden bypassear si hay un information leak que revele su valor
- **ASLR** se puede bypassear si se filtra alguna dirección de memoria
- **NX** se puede bypassear con técnicas como **Return-Oriented Programming (ROP)**

La seguridad real combina todas las capas simultáneamente, más código bien escrito desde el principio.

---
[Video Demostrativo](https://youtu.be/rY3Mxt0JsG4))
---

## Referencias

- [OWASP: Buffer Overflow](https://owasp.org/www-community/vulnerabilities/Buffer_Overflow)
- [Linux Kernel: ASLR](https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html)
- [GCC Stack Protection](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html)
- [CVE Details: Buffer Errors](https://www.cvedetails.com/vulnerability-list/cweid-119/)
