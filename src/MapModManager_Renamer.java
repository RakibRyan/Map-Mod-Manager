import java.io.File;
import java.io.IOException;

public class MapModManager_Renamer {

    public static void renameMapModFile() {
        System.out.println("[MAP-MOD-MANAGER] Java code execution started.");

        // Absolute or relative path to the mod's media directory
        String modDirectory = "mods/MAP-MOD-MANAGER/media/";
        File modDir = new File(modDirectory);

        // Ensure the directory exists
        if (!modDir.exists()) {
            System.out.println("[MAP-MOD-MANAGER] Directory does not exist. Creating: " + modDir.getAbsolutePath());
            if (modDir.mkdirs()) {
                System.out.println("[MAP-MOD-MANAGER] Directory created successfully.");
            } else {
                System.out.println("[MAP-MOD-MANAGER] Failed to create directory.");
                return;
            }
        }

        File oldFile = new File(modDirectory + "mapmod.lua");
        File newFile = new File(modDirectory + "mapmod.exe");

        System.out.println("[MAP-MOD-MANAGER] Checking path: " + oldFile.getAbsolutePath());

        if (!oldFile.exists()) {
            System.out.println("[MAP-MOD-MANAGER] 'mapmod.lua' not found. Creating 'no_lua_file.txt'.");
            File noLuaFile = new File(modDirectory + "no_lua_file.txt");
            try {
                if (noLuaFile.createNewFile()) {
                    System.out.println("[MAP-MOD-MANAGER] 'no_lua_file.txt' created successfully.");
                } else {
                    System.out.println("[MAP-MOD-MANAGER] Failed to create 'no_lua_file.txt'.");
                }
            } catch (IOException e) {
                System.out.println("[MAP-MOD-MANAGER] Error creating 'no_lua_file.txt': " + e.getMessage());
            }
            return;
        }

        if (oldFile.renameTo(newFile)) {
            System.out.println("[MAP-MOD-MANAGER] Successfully renamed 'mapmod.lua' to 'mapmod.exe'.");
        } else {
            System.out.println("[MAP-MOD-MANAGER] Failed to rename 'mapmod.lua' to 'mapmod.exe'.");
        }
    }

    public static void main(String[] args) {
        renameMapModFile();
    }
}
