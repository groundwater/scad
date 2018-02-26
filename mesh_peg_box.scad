module hook(
    lower_depth = 3.5,
    thickness = 3.5,
    arc_size = 2,
    upper_height = 1.5
) {
    d = thickness;
    uh = upper_height;
    h = lower_depth;
    k = arc_size;

    rotate(90, [1,0,0])
    rotate(90, [0,0,-1])
    union() {
        
        // bottom peg
        linear_extrude(h)
        circle(d=d);
        
        // elbow
        translate([-k - d/2, 0, h])
        rotate(90,[1,0,0])
        rotate_extrude(angle = 90)
        translate([d/2 + k, 0])
        circle(d = d);
        
        // top cylinder
        translate([-uh - k - d/2, 0, d/2])
        rotate(90, [0,1,0])
        translate([-h - k,0,0])
        linear_extrude(uh)
        circle(d = d);
        
        // top cap
        translate([-uh - k - d/2, 0, h + k + d/2])
        rotate(90, [0,0,1])
        intersection() {
            sphere(d=d);
           
            translate([-50,0,-50])
            cube([100,100,100]);
        }

    }
}

module peg(
    lower_depth = 3.5,
    thickness = 3.5,
    arc_size = 2,
    upper_height = 1.5
) {
    d = thickness;
    uh = upper_height;
    h = lower_depth;
    k = arc_size;

    translate([0,-h,0])
    mirror([0,1,0])
    union() {
        intersection() {
            sphere(d=d);
            
            translate([-50,0,-50])
            cube([100,100,100]);
        }
        rotate(90, [1,0,0])
        rotate(90, [0,0,-1])
        union() {
            linear_extrude(h)
            circle(d=d);
        }
    }
}

module cup(l=50, h=50, w=50, ww = 2, wc = 10) {    
    module corner(h) {
        scale([1, 1, h])
        rotate_extrude(angle = 90)
        translate([wc, 0, 0])
        scale([ww, 1, 1])
        square(1);
    }
    
    module wall(s, h) {
        scale([s, ww, h])
        linear_extrude(1)
        square(1);
    }
    
    module front(h) {
        mirror([0,1,0])
        translate([l + wc, -wc-ww, 0])
        corner(h);

        translate([wc, wc + ww, 0])
        rotate(180, [0,0,1])
        corner(h);
        
        translate([wc,0,0])
        wall(l, h);
    }

    module walls(h) {
        front(h);
        
        mirror([0,1,0])
        translate([0, -w - 2*ww - 2*wc, 0])
        front(h); 
        
        translate([0, wc + ww, 0])
        rotate(90, [0,0,1])
        wall(w, h);


        translate([l + wc + wc + ww, wc + ww, 0])
        rotate(90, [0,0,1])
        wall(w, h);
    }
    
    walls(h);

    hull()
    walls(2);
}

module model_sized_3_cup(
    inner_hole_to_hole = 20.7,
    outer_hole_to_hole = 29.9,

    // wall width
    ww = 2,

    // wall curvature
    wc = 10,

    depth = 50,

    height = 35,
) {
    center_to_center_spacing = (outer_hole_to_hole - inner_hole_to_hole) / 2 + inner_hole_to_hole;

    length = center_to_center_spacing * 3;

    cup(l=length, w=depth, h=height);

    module support(xoffset, top) {
        hook(
            x = xoffset,
            z = top
        );
        peg(
            x = xoffset,
            z = top - center_to_center_spacing
        );
    }

    support((length)/3+ wc - center_to_center_spacing/2, height - 5);
    support((length)*2/3+ wc - center_to_center_spacing/2, height - 5);
    support((length)+ wc - center_to_center_spacing/2, height - 5);
}

module straight_hook(
    arm_length = 55,
    arm_rise = 10,
    arm_height = 5,
    arm_wall_size = 2,
    
    tip_height = 10,
    tip_depth = 2,

    wing_end_width = 10,
    wing_tip_width = 4,
    wing_height = 2
) {
   
    rotate(90, [0, 0, 1])
    rotate(90, [1, 0, 0])
    linear_extrude(arm_wall_size)
    polygon(points = [
        [0, 0],
        [arm_length, arm_rise],
        [arm_length, arm_rise + arm_height],
        [0, arm_height + wing_height]
    ]);
    
    translate([0, arm_length, arm_rise])
    rotate(90, [1,0,0])
    linear_extrude(arm_wall_size)
    scale([tip_depth, tip_height])
    square(1);

    points = [
         [0,0,0],
         [0,0,wing_height],
         [wing_end_width, 0, wing_height],
         [wing_end_width, 0, 0],
         [wing_end_width/2 + wing_tip_width/2, arm_length, arm_rise],
         [wing_end_width/2 + wing_tip_width/2, arm_length, arm_rise + wing_height],
         [wing_end_width/2 - wing_tip_width/2, arm_length, arm_rise],
         [wing_end_width/2 - wing_tip_width/2, arm_length, arm_rise + wing_height]
    ];
    faces = [
        [0,1,2,3],
        [2,3,4,5],
        [4,5,6,7],
        [6,7,0,1],
        [1,2,5,7],
        [0,3,4,6]
    ];

    translate([-wing_end_width/2 + arm_wall_size/2, 0, arm_height/2])
    hull()
    polyhedron(points = points, faces = faces);
}

module model_single_hook(arm_length = 30, arm_rise = 10) {
    inner_hole_to_hole = 20.7;
    outer_hole_to_hole = 29.9;
    center_to_center_spacing = (outer_hole_to_hole - inner_hole_to_hole) / 2 + inner_hole_to_hole;
    
    back_plate_thickness = 4;
    
    theta = atan(arm_rise / arm_length);

    translate([0, 0, 10])
    straight_hook(
        arm_length,
        arm_rise,
        arm_height = 5,
        arm_wall_size = 2,
        
        tip_height = 10,
        tip_depth = 2,

        wing_end_width = 10,
        wing_tip_width = 4,
        wing_height = 2
    );
    
    module back() {
        translate([1,0,.2]) {
            translate([0,0,center_to_center_spacing])
            hook(
                lower_depth = 3.5 + back_plate_thickness,
                thickness = 3.75,
                arc_size = .5,
                upper_height = 1.5
            );
            peg(
                lower_depth = 3.5 + back_plate_thickness,
                thickness = 3.75,
                upper_height = 1.5
            );
        }
        
        translate([-4,2,-2.5])
        rotate(90, [1,0,0])
        linear_extrude(back_plate_thickness)
        scale([10,center_to_center_spacing + 5  ])
        square(1);
    }
        
    // we want an angled back-plate to create a flat print surface
    difference() {
        translate([0,0,2])
        back();

        rotate(theta, [1,0,0])
        mirror([0,0,1])
        translate([-50, -50, 0])
        cube([100,100,100]);
    }
}

module mesh(
    fill_spacing = 20,
    fill_theta = 55,
    fill_thickness = 1.5,
    fill_infill = 1.5,

    wall_height = 25,
    wall_length = 105
) {
    fill_delta_1 = tan(fill_theta) * fill_thickness;
    fill_delta_2 = wall_height / cos(fill_theta);
    fill_delta = fill_delta_1 + fill_delta_2;
    intersection() {
        for(i = [-wall_length:fill_spacing:wall_length]) {
            translate([0, i, 0])
            rotate(fill_theta, [0,0,1])
            linear_extrude(fill_infill)
            scale([fill_delta, fill_thickness])
            square(1);

            translate([0, wall_length - i, 0])
            rotate(fill_theta, [0,0,-1])
            linear_extrude(fill_infill)
            scale([fill_delta, -fill_thickness])
            square(1);
        }

        color([1,0,0,.25])
        linear_extrude(fill_infill)
        scale([wall_height, wall_length])
        square(1);
    }
}

module mesh_wall(
    side_length,
    side_height,

    side_margin = 2,
    side_thickness = 2,

    fill_spacing = 15,
    fill_theta = 55,
    fill_thickness = 1.5,
    fill_infill = 1
) {
    difference() {
        scale([side_height, side_length])
        linear_extrude(side_thickness)
        square(1);

        translate([side_margin, side_margin, 0])
        scale([side_height - 2*side_margin, side_length - 2*side_margin])
        linear_extrude(side_thickness)
        square(1);
    }

    translate([side_margin, side_margin, (side_thickness-fill_infill)/2])
    mesh(
        fill_spacing,
        fill_theta,
        fill_thickness,
        fill_infill,
        side_height - 2*side_margin,
        side_length - 2*side_margin
   );
}

module assemble_walls(length, width, height) {
    translate([0,0,height])
    rotate(90, [0,1,0])
    children(0);
    
    rotate(90, [0,0,-1])
    rotate(-90, [0,1,0])
    children(1);

    translate([length, 0, 0])
    rotate(-90, [0,1,0])
    children(2);

    translate([0, width, height])
    rotate(90, [0,0,-1])
    rotate(90, [0,1,0])
    children(3);
    
    children(4);
}

module model_wire_box(length, width, height) {
    module make_pegs(begin = 0, until = width, c2c_spacing = 25.3) {
        for (a =[begin:c2c_spacing:until]) translate([a,0,25]) children(0);
        for (a =[begin:c2c_spacing:until]) translate([a,0,0]) children(1);
    }

    translate([2, 12, 2])
    mirror([1,0,0])
    rotate(90, [0,0,1])
    make_pegs() {
        hook(lower_depth = 5.5); 
        peg(lower_depth = 5.5);
    };
    assemble_walls(length, width, height) {
        mesh_wall(width, height, side_margin = 4);
        mesh_wall(length, height);
        mesh_wall(width, height);
        mesh_wall(length, height);
        mesh_wall(width, length);
    }
}

model_wire_box(50, 50, 40);
