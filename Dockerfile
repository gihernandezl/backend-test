# Imagen base
FROM node:18

# Directorio de trabajo
WORKDIR /app

# Copiar package.json e instalar dependencias
COPY package*.json ./
RUN npm install

# Copiar el resto del código
COPY . .

# Compilar la app NestJS
RUN npm run build

# Exponer puerto de NestJS
EXPOSE 3000

# Comando para producción
CMD ["npm", "run", "start:prod"]
