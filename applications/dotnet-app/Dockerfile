FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy source code and build
COPY . .
RUN dotnet build -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Final stage
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app

# Copy published files
COPY --from=publish /app/publish .

# Set environment variables
ENV APP_NAME=dotnet-app
ENV ENVIRONMENT=development

# Run the application
ENTRYPOINT ["dotnet", "LoggingApp.dll"]
