# Claude Code Constants and Configuration

<document type="constants" domain="claude-code" version="3.1">
    <metadata>
        <title>Claude Code Constants and Configuration</title>
        <claude-optimization>true</claude-optimization>
        <scope>claude-code-domain</scope>
        <category>claude-code</category>
        <mutability>read-only</mutability>
        <validation-frequency>weekly</validation-frequency>
        <navigation>
            <index>@NAVIGATION.md</index>
            <related>@../../00_GLOBAL_CONSTANTS.md</related>
        </navigation>
    </metadata>

    <summary>
        Central repository for Claude Code commands, configurations, and feature specifications.
        Single source of truth for all Claude Code documentation to reference instead of duplicating values.
    </summary>

    <content>
        <section type="constants" id="commands">
            <technical-explanation>
                Claude Code's command interface provides structured interactions with AI systems through
                standardized commands. These commands control context management, thinking modes, MCP integration,
                and productivity features with consistent syntax and behavior patterns.
            </technical-explanation>
            <simple-explanation>
                Think of these like magic words that tell Claude Code what to do. Instead of describing what
                you want in sentences, you can use these shortcuts to quickly control memory, thinking power,
                connect to other tools, and work more efficiently.
            </simple-explanation>

            <constants>
                <constant>
                    <name>CONTEXT_MANAGEMENT_COMMANDS</name>
                    <value>/init, /clear, /compact, # [note], /memory</value>
                    <description>Commands for controlling conversation memory and context</description>
                </constant>

                <constant>
                    <name>THINKING_MODES_TRIGGERS</name>
                    <value>think, think hard, think harder, ultrathink</value>
                    <description>Progressive reasoning enhancement commands</description>
                </constant>

                <constant>
                    <name>MCP_COMMANDS</name>
                    <value>claude mcp add [server], claude mcp list, @[resource], /mcp__server__prompt</value>
                    <description>Model Context Protocol integration commands</description>
                </constant>

                <constant>
                    <name>PRODUCTIVITY_SHORTCUTS</name>
                    <value>[Tab], [Escape], [Escape][Escape], @filename</value>
                    <description>Keyboard shortcuts for efficient interaction</description>
                </constant>
            </constants>

            <command-details>
                <context-management>
                    <command>/init</command>
                    <purpose>Initialize project memory hierarchy</purpose>
                    <technical>Establishes CLAUDE.md file structure and loads project context</technical>
                    <simple>Sets up your workspace so Claude remembers your project details</simple>
                </context-management>

                <thinking-modes>
                    <command>ultrathink</command>
                    <purpose>Maximum reasoning budget allocation</purpose>
                    <technical>Allocates maximum computational resources for complex problem solving</technical>
                    <simple>Tells Claude to think as deeply as possible about hard problems</simple>
                </thinking-modes>

                <mcp-integration>
                    <command>claude mcp add [server]</command>
                    <purpose>Install external tool integration</purpose>
                    <technical>Configures Model Context Protocol server for tool interoperability</technical>
                    <simple>Connects Claude to other tools like GitHub, research databases, or audio systems</simple>
                </mcp-integration>
            </command-details>
        </section>

        <section type="constants" id="configuration">
            <technical-explanation>
                Claude Code configuration defines memory hierarchy, performance optimization, and system
                behavior parameters. These settings control how context is managed, thinking resources are
                allocated, and semantic understanding is enhanced through XML tagging.
            </technical-explanation>
            <simple-explanation>
                These are the settings that control how Claude Code works - like adjusting the volume,
                brightness, and other preferences on your phone to make it work better for you.
            </simple-explanation>

            <constants>
                <constant>
                    <name>MEMORY_HIERARCHY_LEVELS</name>
                    <value>4</value>
                    <description>Number of hierarchical memory levels (global→project→directory→personal)</description>
                </constant>

                <constant>
                    <name>XML_SEMANTIC_BOOST</name>
                    <value>40%</value>
                    <description>Performance improvement from XML semantic tagging</description>
                </constant>

                <constant>
                    <name>THINKING_BUDGET_MULTIPLIERS</name>
                    <value>1x, 2x, 4x, unlimited</value>
                    <description>Computational resource allocation for thinking modes</description>
                </constant>
            </constants>

            <memory-hierarchy>
                <level priority="1" scope="global">~/.claude/CLAUDE.md</level>
                <level priority="2" scope="project">./CLAUDE.md</level>
                <level priority="3" scope="directory">subdirectory/CLAUDE.md</level>
                <level priority="4" scope="personal">CLAUDE.local.md</level>
            </memory-hierarchy>
        </section>

        <section type="constants" id="hooks-system">
            <technical-explanation>
                The hooks system provides event-driven automation through lifecycle callbacks.
                Hooks execute automatically at specific events (pre/post tool use, session completion)
                enabling quality assurance, documentation, and monitoring workflows.
            </technical-explanation>
            <simple-explanation>
                Hooks are like automatic reminders that do helpful things at the right time -
                like automatically checking your work before saving or keeping track of what you did.
            </simple-explanation>

            <constants>
                <constant>
                    <name>HOOK_EVENTS</name>
                    <value>pre_tool_use, post_tool_use, session_complete</value>
                    <description>Available lifecycle events for automation</description>
                </constant>

                <constant>
                    <name>PRE_COMMIT_HOOK</name>
                    <value>ruff check . && black . && pytest tests/</value>
                    <description>Code quality validation before file changes</description>
                </constant>

                <constant>
                    <name>SESSION_SUMMARY_HOOK</name>
                    <value>git add . && git commit -m 'Session: $(date)'</value>
                    <description>Automatic session documentation and versioning</description>
                </constant>
            </constants>

            <hook-examples>
                <hook name="pre-commit" event="pre-tool-use">
                    <technical>Automated code quality enforcement using ruff linting, black formatting, and pytest testing</technical>
                    <simple>Like having a careful friend check your homework before you submit it</simple>
                    <command>ruff check . && black . && pytest tests/</command>
                </hook>

                <hook name="session-summary" event="session-complete">
                    <technical>Automated git commit with timestamp for session documentation and version tracking</technical>
                    <simple>Like automatically saving your progress with a note about when you worked</simple>
                    <command>git add . && git commit -m "Session: $(date)"</command>
                </hook>
            </hook-examples>
        </section>

        <section type="constants" id="mcp-integration">
            <technical-explanation>
                Model Context Protocol (MCP) enables Claude Code to integrate with external systems
                through standardized server interfaces. MCP servers provide capabilities like GitHub integration,
                enhanced file operations, web search, and text-to-speech services.
            </technical-explanation>
            <simple-explanation>
                MCP is like adding specialized assistants to your team - one that knows GitHub,
                another that can search the web, another that can create audio files. Each one
                brings special skills that Claude Code can use.
            </simple-explanation>

            <constants>
                <constant>
                    <name>HIGH_PRIORITY_SERVERS</name>
                    <value>github, elevenlabs</value>
                    <description>MCP servers with high integration priority</description>
                </constant>

                <constant>
                    <name>MCP_SETUP_COMMAND</name>
                    <value>claude mcp add [server-name]</value>
                    <description>Standard command for installing MCP servers</description>
                </constant>
            </constants>

            <mcp-servers>
                <server name="github" priority="high">
                    <capabilities>issues, PRs, repos</capabilities>
                    <setup>claude mcp add github</setup>
                    <technical>Repository management, issue tracking, and pull request automation</technical>
                    <simple>Connects to GitHub so Claude can help with code projects and collaboration</simple>
                </server>

                <server name="filesystem" priority="medium">
                    <capabilities>enhanced file ops</capabilities>
                    <setup>claude mcp add filesystem</setup>
                    <technical>Advanced file system operations beyond basic read/write functionality</technical>
                    <simple>Gives Claude more powerful ways to work with files and folders</simple>
                </server>

                <server name="elevenlabs" priority="high">
                    <capabilities>TTS, voice clone, transcribe</capabilities>
                    <setup>claude mcp add elevenlabs</setup>
                    <technical>High-quality text-to-speech synthesis with voice cloning and transcription capabilities</technical>
                    <simple>Lets Claude create realistic-sounding speech from text, like a professional narrator</simple>
                </server>
            </mcp-servers>
        </section>

        <section type="constants" id="directory-structure">
            <technical-explanation>
                Claude Code follows standardized directory conventions for commands, hooks, memory files,
                context documentation, and session tracking. This structure enables predictable file
                organization and automated tool discovery.
            </technical-explanation>
            <simple-explanation>
                Like having specific drawers for different types of items - commands in one place,
                memory files in another, so everything has a logical home that's easy to find.
            </simple-explanation>

            <constants>
                <constant>
                    <name>CLAUDE_DIRECTORIES</name>
                    <value>.claude/commands/, .claude/hooks/, .claude/context/, .claude/sessions/</value>
                    <description>Standard directory structure for Claude Code organization</description>
                </constant>

                <constant>
                    <name>FILE_NAMING_PATTERNS</name>
                    <value>[name].md, [event]-[name].sh, CLAUDE.md, CLAUDE.local.md</value>
                    <description>Standardized file naming conventions</description>
                </constant>
            </constants>
        </section>

        <section type="constants" id="features-capabilities">
            <technical-explanation>
                Claude Code feature flags and capability toggles that control system behavior,
                including memory management, XML semantic tagging, hooks integration, and
                advanced thinking modes with ultrathink support.
            </technical-explanation>
            <simple-explanation>
                These are like switches that turn different Claude Code features on or off,
                making it work exactly how you want for your specific projects and needs.
            </simple-explanation>

            <constants>
                <constant>
                    <name>ENABLED_FEATURES</name>
                    <value>memory_management, xml_semantic_tagging, hooks_integration, mcp_servers, ultrathink</value>
                    <description>Core Claude Code features that are enabled by default</description>
                </constant>

                <constant>
                    <name>OPTIMIZATION_FEATURES</name>
                    <value>tab_completion, escape_interruption, session_continuity</value>
                    <description>Productivity and user experience enhancements</description>
                </constant>
            </constants>
        </section>

        <section type="constants" id="optimization-settings">
            <technical-explanation>
                Context optimization parameters control when conversations should be cleared or compacted
                to maintain optimal performance. Claudeignore patterns exclude irrelevant files from
                context loading to reduce noise and improve focus.
            </technical-explanation>
            <simple-explanation>
                These settings help keep Claude Code running smoothly by cleaning up old conversations
                when they get too long, and ignoring files that would just be distracting.
            </simple-explanation>

            <constants>
                <constant>
                    <name>CLEAR_FREQUENCY</name>
                    <value>Every 3-5 major tasks</value>
                    <description>Recommended frequency for clearing conversation context</description>
                </constant>

                <constant>
                    <name>COMPACT_THRESHOLD</name>
                    <value>Context > 50% full</value>
                    <description>When to trigger conversation compaction</description>
                </constant>

                <constant>
                    <name>IGNORE_PATTERNS</name>
                    <value>node_modules/, .git/, __pycache__/, *.log, .DS_Store, .env, dist/, build/, venv/</value>
                    <description>File patterns excluded from context loading</description>
                </constant>
            </constants>
        </section>
    </content>

    <cross-references>
        <reference file="../../00_GLOBAL_CONSTANTS.md" section="global-project" type="parent">
            Global project constants and specifications
        </reference>
        <reference file="16_memory_management_system.md" section="memory-hierarchy" type="implementation">
            Memory system implementation guide
        </reference>
        <reference file="17_command_reference_guide.md" section="commands" type="implementation">
            Detailed command usage and examples
        </reference>
        <reference file="19_thinking_modes_guide.md" section="thinking-modes" type="implementation">
            Thinking modes configuration and optimization
        </reference>
        <reference file="20_hooks_automation_system.md" section="hooks" type="implementation">
            Hooks system setup and automation workflows
        </reference>
        <reference file="21_mcp_integration_guide.md" section="mcp-servers" type="implementation">
            MCP server integration and configuration
        </reference>
    </cross-references>

    <validation>
        <validation-command>grep -r "CONTEXT_MANAGEMENT_COMMANDS" .claude/context/claude-code/</validation-command>
        <success-criteria>All referenced constants exist and are properly formatted</success-criteria>
    </validation>
</document>
