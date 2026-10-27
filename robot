import bpy
import math
from mathutils import Vector


bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()


def create_material(name, color, roughness=0.5, metallic=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    
    bsdf = None
    for node in nodes:
        if node.type == 'BSDF_PRINCIPLED':
            bsdf = node
            break
    
    if bsdf is None:
        raise ValueError("Principled BSDF node not found")
    
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = metallic
    return mat

def create_emission_material(name, color, strength=3.0):
    """Светящийся материал (для глаз и панели)"""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    
    for node in list(nodes):
        nodes.remove(node)
    
  
    output = nodes.new('ShaderNodeOutputMaterial')
    emission = nodes.new('ShaderNodeEmission')
    
    emission.inputs['Color'].default_value = color
    emission.inputs['Strength'].default_value = strength
    
    output.location = (300, 0)
    emission.location = (0, 0)
    
    links.new(emission.outputs['Emission'], output.inputs['Surface'])
    return mat


mat_body = create_material("RobotBody", (0.55, 0.58, 0.62, 1.0), roughness=0.35, metallic=0.85)
mat_dark = create_material("RobotDark", (0.15, 0.17, 0.2, 1.0), roughness=0.4, metallic=0.9)
mat_accent = create_material("RobotAccent", (0.2, 0.5, 0.85, 1.0), roughness=0.3, metallic=0.7)
mat_orange = create_material("RobotOrange", (0.95, 0.5, 0.1, 1.0), roughness=0.4, metallic=0.6)
mat_eye = create_emission_material("RobotEye", (0.3, 0.8, 1.0, 1.0), strength=5.0)
mat_panel = create_emission_material("RobotPanel", (0.1, 0.9, 0.5, 1.0), strength=3.0)


def add_robot_part(name, location, scale, material, rotation=(0,0,0), use_cube=False):
    if use_cube:
        bpy.ops.mesh.primitive_cube_add(size=1, location=location, scale=scale)
    else:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=1, location=location, scale=scale)
    
    obj = bpy.context.active_object
    obj.name = name
    obj.rotation_euler = rotation
    obj.data.materials.append(material)
    
    if use_cube:
        bpy.ops.object.modifier_add(type='BEVEL')
        bevel_mod = None
        for mod in obj.modifiers:
            if mod.type == 'BEVEL':
                bevel_mod = mod
                break
        
        if bevel_mod:
            bevel_mod.width = 0.05
            bevel_mod.segments = 3
    
    bpy.ops.object.shade_smooth()
    return obj




add_robot_part("Head", (0, 0, 4.5), (1.1, 0.9, 0.85), mat_body, use_cube=True)
add_robot_part("FacePlate", (0, 0.35, 4.45), (0.85, 0.2, 0.6), mat_dark, use_cube=True)
add_robot_part("Eye_L", (0.35, 0.55, 4.55), (0.18, 0.12, 0.18), mat_eye)
add_robot_part("Eye_R", (-0.35, 0.55, 4.55), (0.18, 0.12, 0.18), mat_eye)
add_robot_part("Antenna_Stick", (0, 0, 5.35), (0.05, 0.05, 0.35), mat_dark)
add_robot_part("Antenna_Ball", (0, 0, 5.75), (0.1, 0.1, 0.1), mat_orange)
add_robot_part("Ear_L", (0.6, 0, 4.5), (0.12, 0.3, 0.25), mat_accent, use_cube=True)
add_robot_part("Ear_R", (-0.6, 0, 4.5), (0.12, 0.3, 0.25), mat_accent, use_cube=True)


add_robot_part("Neck", (0, 0, 3.85), (0.3, 0.3, 0.2), mat_dark)


add_robot_part("Torso", (0, 0, 2.7), (1.4, 1.1, 1.6), mat_body, use_cube=True)
add_robot_part("ChestPanel", (0, 0.56, 2.9), (0.7, 0.08, 0.5), mat_panel, use_cube=True)
add_robot_part("ChestButton", (0, 0.58, 2.3), (0.15, 0.08, 0.15), mat_orange)
add_robot_part("Stripe_L", (0.72, 0, 2.7), (0.05, 0.9, 1.2), mat_accent, use_cube=True)
add_robot_part("Stripe_R", (-0.72, 0, 2.7), (0.05, 0.9, 1.2), mat_accent, use_cube=True)


add_robot_part("Shoulder_L", (1.0, 0, 3.3), (0.35, 0.35, 0.35), mat_accent)
add_robot_part("Shoulder_R", (-1.0, 0, 3.3), (0.35, 0.35, 0.35), mat_accent)
add_robot_part("Arm_L", (1.1, 0, 2.4), (0.22, 0.22, 0.7), mat_dark)
add_robot_part("Arm_R", (-1.1, 0, 2.4), (0.22, 0.22, 0.7), mat_dark)
add_robot_part("Hand_L", (1.1, 0, 1.55), (0.28, 0.28, 0.22), mat_orange)
add_robot_part("Hand_R", (-1.1, 0, 1.55), (0.28, 0.28, 0.22), mat_orange)


add_robot_part("Hip_L", (0.45, 0, 1.6), (0.3, 0.3, 0.25), mat_accent)
add_robot_part("Hip_R", (-0.45, 0, 1.6), (0.3, 0.3, 0.25), mat_accent)
add_robot_part("Leg_L", (0.45, 0, 0.9), (0.25, 0.25, 0.6), mat_dark)
add_robot_part("Leg_R", (-0.45, 0, 0.9), (0.25, 0.25, 0.6), mat_dark)
add_robot_part("Knee_L", (0.45, 0, 1.2), (0.18, 0.18, 0.18), mat_orange)
add_robot_part("Knee_R", (-0.45, 0, 1.2), (0.18, 0.18, 0.18), mat_orange)
add_robot_part("Foot_L", (0.45, 0.15, 0.15), (0.35, 0.5, 0.2), mat_body, use_cube=True)
add_robot_part("Foot_R", (-0.45, 0.15, 0.15), (0.35, 0.5, 0.2), mat_body, use_cube=True)


bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, 0))
ground = bpy.context.active_object
ground.name = "Ground"
ground.data.materials.append(create_material("Ground", (0.25, 0.27, 0.3, 1.0), roughness=0.8))

world = bpy.context.scene.world
if world is None:
    world = bpy.data.worlds.new("World")
    bpy.context.scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes["Background"]
bg.inputs['Color'].default_value = (0.08, 0.1, 0.15, 1.0)
bg.inputs['Strength'].default_value = 0.3


robot_center = Vector((0, 0, 3))


bpy.ops.object.light_add(type='AREA', radius=3, location=(3, 10, 8))
light = bpy.context.active_object
light.name = "KeyLight"
light.data.energy = 700
light.data.size = 6
direction = robot_center - light.location 
rot_quat = direction.to_track_quat('-Z', 'Y')
light.rotation_euler = rot_quat.to_euler()


bpy.ops.object.light_add(type='AREA', radius=2, location=(-6, 8, 5))
fill_light = bpy.context.active_object
fill_light.name = "FillLight"
fill_light.data.energy = 300
fill_light.data.size = 4
direction = robot_center - fill_light.location
rot_quat = direction.to_track_quat('-Z', 'Y')
fill_light.rotation_euler = rot_quat.to_euler()


bpy.ops.object.light_add(type='AREA', radius=2, location=(0, -8, 5))
rim_light = bpy.context.active_object
rim_light.name = "RimLight"
rim_light.data.energy = 450
rim_light.data.size = 4
direction = robot_center - rim_light.location
rot_quat = direction.to_track_quat('-Z', 'Y')
rim_light.rotation_euler = rot_quat.to_euler()


bpy.ops.object.camera_add(location=(0, 16, 3.0))
cam = bpy.context.active_object
cam.name = "Camera"
cam.data.lens = 50


aim_point = Vector((0, 0, 2.9))
direction = aim_point - cam.location
rot_quat = direction.to_track_quat('-Z', 'Y')
cam.rotation_euler = rot_quat.to_euler()

bpy.context.scene.camera = cam


scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.filepath = "//robot_full_render.png"

scene.view_settings.view_transform = 'Standard'

print("Начинаю рендер полного робота с ногами...")
bpy.ops.render.render(write_still=True)
print("Рендер завершен! Файл: robot_full_render.png")
