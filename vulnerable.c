#include <stdio.h>
#include <string.h>

// Esta funcion nunca deberia ejecutarse en condiciones normales.
// Si aparece en la salida, significa que el return address fue sobrescrito.
void secret_function() {
    printf("[!] secret_function() ejecutada — esto no deberia pasar!\n");
}

// Funcion vulnerable: usa strcpy sin verificar el tamanio del input.
// buffer tiene 64 bytes; cualquier input mayor desborda hacia el stack.
void vulnerable(char *input) {
    char buffer[64];
    strcpy(buffer, input); // PELIGRO: sin limite de tamanio
    printf("Buffer contiene: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <input>\n", argv[0]);
        return 1;
    }

    printf("Direccion de secret_function : %p\n", (void*)secret_function);
    printf("Direccion del buffer (aprox)  : %p\n", (void*)vulnerable);

    vulnerable(argv[1]);

    printf("Programa termino normalmente.\n");
    return 0;
}
