.SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

REPO_URL := https://github.com/NotPrath19/archi-server.git
REPO_NAME := archi-server

.PHONY: all deploy build push

all: deploy

# 1. Build all services (no push)
build:
	@echo "🔨 Building all services..."
	@$(MAKE) -C archi-webapp build-dist
	@$(MAKE) -C micro-service/archi build
	@$(MAKE) -C micro-service/calendar build
	@$(MAKE) -C micro-service/connect build
	@$(MAKE) -C micro-service/processor build
	@$(MAKE) -C micro-service/story build
	@$(MAKE) -C micro-service/sdk build

# 2. Push both JARs and dist/ in a single commit
push:
	@if [ ! -d "$(REPO_NAME)" ]; then \
		echo "📥 Cloning repo..."; \
		git clone $(REPO_URL); \
	else \
		echo "📂 Repo already cloned."; \
	fi

	@echo "🔄 Pulling latest changes..."
	@cd $(REPO_NAME) && \
	if ! git diff --quiet || ! git diff --cached --quiet; then \
		echo "💾 Stashing local changes..."; \
		git stash push -m "temp-stash-for-make"; \
		git pull --rebase; \
		echo "📤 Restoring local changes..."; \
		git stash pop; \
	else \
		git pull --rebase; \
	fi

	@echo "🧹 Cleaning old jars and dist..."
	@rm -rf $(REPO_NAME)/jars
	@rm -rf $(REPO_NAME)/dist

	@echo "📦 Copying new JARs..."
	@mkdir -p $(REPO_NAME)/jars
	@cp -f micro-service/calendar/target/calendar-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/
	@cp -f micro-service/connect/target/connect-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/
	@cp -f micro-service/story/target/story-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/
	@cp -f micro-service/sdk/target/sdk-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/
	@cp -f micro-service/archi/target/archi-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/
	@cp -f micro-service/processor/target/processor-0.0.1-SNAPSHOT.jar $(REPO_NAME)/jars/

	@echo "🌐 Copying Angular dist..."
	@mkdir -p $(REPO_NAME)/dist
	@cp -r archi-webapp/dist/* $(REPO_NAME)/dist/

	@echo "📌 Ensuring LFS tracking..."
	@cd $(REPO_NAME) && git lfs track "jars/*.jar"
	@cd $(REPO_NAME) && git add .gitattributes

	@echo "📤 Committing and pushing changes..."
	@cd $(REPO_NAME) && \
	git add jars/ dist/ && \
	git commit -m "📦 Update JARs and 🚀 Update dist folder" || echo "✅ Nothing to commit"; \
	git push origin main

# Combined target
deploy: build push