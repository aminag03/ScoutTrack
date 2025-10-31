FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ScoutTrack.Subscriber/ScoutTrack.Subscriber.csproj", "ScoutTrack.Subscriber/"]
COPY ["Common/Common.csproj", "Common/"]
COPY ["ScoutTrack.Model/ScoutTrack.Model.csproj", "ScoutTrack.Model/"]
COPY ["ScoutTrack.Services/ScoutTrack.Services.csproj", "ScoutTrack.Services/"]
RUN dotnet restore "ScoutTrack.Subscriber/ScoutTrack.Subscriber.csproj"
COPY . .
WORKDIR "/src/ScoutTrack.Subscriber"
RUN dotnet build "ScoutTrack.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ScoutTrack.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ScoutTrack.Subscriber/appsettings.json .
ENTRYPOINT ["dotnet", "ScoutTrack.Subscriber.dll"]