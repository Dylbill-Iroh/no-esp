-- No .esp (by Mrowr Purr, MIT) built with xmake and CommonLibSSE-NG, from Dylbill's SKSE plugin template.
-- Replaces CMakeLists.txt / CMakePresets.json / vcpkg.json (those can stay, xmake ignores them).

-- packages from xmake-repo
add_requires("simpleini")   -- replaces vcpkg's simpleini (include/NoESP/Config.h)

-- include CommonLibSSE-NG: use the shared copy from the CommonLibSSE_PATH environment variable if it's set.
-- CommonLibSSE_PATH Should point to where the xmake.lua is in commonlib. E.G C:\MODS\SksePlugins\commonlibsse-ng
-- Otherwise fall back to the local submodule
local commonlib_dir = os.getenv("CommonLibSSE_PATH")
if commonlib_dir and os.isfile(path.join(commonlib_dir, "xmake.lua")) then
    includes(commonlib_dir)
else
    if commonlib_dir then
        print("CommonLibSSE_PATH (%s) has no xmake.lua, using lib/commonlibsse-ng", commonlib_dir)
    end
    includes("lib/commonlibsse-ng")
end

-- set project constants
set_project("no-esp")
set_version("1.3.0")
set_license("GPL-3.0")
set_languages("c++23")
set_warnings("all")

-- add common rules
add_rules("mode.debug", "mode.releasedbg")
set_defaultmode("releasedbg")
add_rules("plugin.vsxmake.autoupdate")
add_rules("plugin.compile_commands.autoupdate", { outputdir = "." })

-- =====================================================================================================================
-- config. Run commands in the vscode terminal.
-- for the first time building, run this command:
-- xmake f -c -y -p windows -a x64 -m releasedbg --toolchain=msvc
-- xmake -r

-- with releasedbg
-- xmake f -m releasedbg
-- xmake -r

-- check options
-- xmake f --menu

-- update intellisence
-- xmake project -k compile_commands 
-- reset clangd language server

-- =====================================================================================================================

target("no-esp")
    add_rules("commonlibsse-ng.plugin", {
        name = "no-esp",
        author = "Mrowr Purr / Dylbill",
        description = "No .esp - attach Papyrus scripts without an .esp"
    })

    add_packages("simpleini")

    -- the old CMakeLists.txt set these. UNICODE is required: Config.h uses wide L"..." keys with CSimpleIni,
    -- which is CSimpleIniW only when UNICODE is defined.
    add_defines("UNICODE", "_UNICODE", "NOMINMAX", "_CRT_SECURE_NO_WARNINGS")

    -- sources: src/plugin.cpp. All the other code is header only, in include/NoESP.
    -- test/ (bandit unit tests) isn't built.
    add_files("src/**.cpp")
    add_headerfiles("src/**.h", "include/**.h")
    add_includedirs("src", "include")
    set_pcxxheader("src/PCH.h")

    -- copy the .dll, .pdb and no-esp.ini to the game folders after every build. Folders not found are skipped.
    after_build(function (target)
        local deploy_folders = {
            "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition AE 1-7-104/Data/SKSE/Plugins",
            "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition SE 1-5-97/Data/SKSE/Plugins",
            "C:/MODS/My Mods/No ESP - NG/Releases/No ESP - NG/SKSE/Plugins"
        }

        local dll = target:targetfile()
        local pdb = target:symbolfile()
        local ini = path.join(os.projectdir(), "no-esp.ini")

        for _, folder in ipairs(deploy_folders) do
            local data_folder = path.directory(path.directory(folder))
            if os.isdir(data_folder) then
                os.mkdir(folder)
                os.cp(dll, folder)
                if pdb and os.isfile(pdb) then
                    os.cp(pdb, folder)
                end
                if os.isfile(ini) and not os.isfile(path.join(folder, "no-esp.ini")) then
                    os.cp(ini, folder)   -- only if missing, so your own settings aren't overwritten
                end
                cprint("${green}[deploy]: copied %s to %s", path.filename(dll), folder)
            else
                cprint("${yellow}[deploy]: skipped, folder not found: %s", data_folder)
            end
        end
    end)
