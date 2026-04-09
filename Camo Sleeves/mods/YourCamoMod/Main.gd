extends Node

var modifiedRes: Array = []

func _ready():
    await get_tree().process_frame
    await get_tree().process_frame
    
    var db = get_node_or_null("/root/Database")
    if db == null:
        push_warning("[StrichtarnSleeves] Database not found!")
        return
    
    # Get item data from the packed scene
    var scene = db.Jacket_M62
    var item_path = scene.resource_path.replace(".tscn", ".tres")
    var item = ResourceLoader.load(item_path, "", ResourceLoader.CACHE_MODE_REUSE)
    
    if item:
        item.name = "Strichtarn Jacket"
        item.inventory = "Strichtarn Jacket"
        item.rotated = "Strichtarn Jacket"
        item.equipment = "Strichtarn J."
        item.display = "Strichtarn J."
        modifiedRes.append(item)
        print("[StrichtarnSleeves] Item names patched OK")
    else:
        push_warning("[StrichtarnSleeves] Failed to load item data")
    
    # Patch sleeve textures
    var mat = ResourceLoader.load("res://Items/Clothing/Jacket_M62/Files/MT_Jacket_M62_Sleeves.tres", "", ResourceLoader.CACHE_MODE_REUSE)
    if mat:
        var image = Image.new()
        var err = image.load("res://mods/StrichtarnSleeves/TX_Jacket_M62_Sleeves_AL.png")
        if err == OK:
            var sleeve_tex = ImageTexture.create_from_image(image)
            mat.set_shader_parameter("albedo", sleeve_tex)
            modifiedRes.append(sleeve_tex)
            print("[StrichtarnSleeves] Sleeve albedo patched OK")
        else:
            push_warning("[StrichtarnSleeves] Failed to load sleeve albedo PNG, error: " + str(err))
        
        var image_nr = Image.new()
        var err_nr = image_nr.load("res://mods/StrichtarnSleeves/TX_Jacket_M62_Sleeves_NR.png")
        if err_nr == OK:
            var normal_tex = ImageTexture.create_from_image(image_nr)
            mat.set_shader_parameter("normal", normal_tex)
            modifiedRes.append(normal_tex)
            print("[StrichtarnSleeves] Sleeve normal map patched OK")
        else:
            push_warning("[StrichtarnSleeves] Failed to load sleeve normal PNG, error: " + str(err_nr))
        
        modifiedRes.append(mat)
    else:
        push_warning("[StrichtarnSleeves] Failed to load sleeve material")
    
    # Load icon texture
    var image2 = Image.new()
    var err2 = image2.load("res://mods/StrichtarnSleeves/Icon_Jacket_M62.png")
    var icon_tex = null
    if err2 == OK:
        icon_tex = ImageTexture.create_from_image(image2)
        if item:
            item.icon = icon_tex
            print("[StrichtarnSleeves] icon_tex type: ", icon_tex.get_class())
            print("[StrichtarnSleeves] item.icon after set: ", item.icon)
            print("[StrichtarnSleeves] Same instance: ", item.icon == icon_tex)
        modifiedRes.append(icon_tex)
        print("[StrichtarnSleeves] Icon texture loaded OK")
    else:
        push_warning("[StrichtarnSleeves] Failed to load icon PNG, error: " + str(err2))
    
    # Wait for scene to fully load then refresh all Item nodes
    await get_tree().create_timer(2.0).timeout
    if icon_tex:
        print("[StrichtarnSleeves] Searching for Item nodes...")
        _refresh_items(get_tree().root, icon_tex)
        print("[StrichtarnSleeves] Search complete")

func _refresh_items(node: Node, icon_tex: ImageTexture):
    if node.get_script() != null:
        var script_name = node.get_script().get_global_name()
        if script_name == "Item":
            if node.has_node("Icon") and "slotData" in node:
                if node.slotData != null and node.slotData.itemData != null:
                    if node.slotData.itemData.file == "Jacket_M62":
                        node.get_node("Icon").texture = icon_tex
                        print("[StrichtarnSleeves] Icon refreshed on node: ", node.name)
    for child in node.get_children():
        _refresh_items(child, icon_tex)