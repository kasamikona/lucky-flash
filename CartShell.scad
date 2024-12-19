// Output settings
render_main = true;
render_cover = false;
prerender = true;
preview_print = true;

// Enhancements
enh_dipswitch = true;
enh_noholes = false;
enh_snapfit = true;
enh_post_supports = true;
enh_pegs_to_slots = true;
enh_label_top = true;

// Main dimensions
main_xsize = 68.8;
main_xslant = 0.3/20;
wall_xy = 1.5;
wall_z = 1.5;
wall_supp = 1.1;
wall_notch = 1.1;
curve_xc = 40.5;
curve_yc = -255;
curve_angle_start = 91;
curve_angle_range = 15.5;
profile_front = 46;
profile_handle_depth = profile_front-10;
profile_handle_slant = 0.12;
profile_handle_chamfer = 4.5;
main_height = 12.7;
handle_height = 15;

// Secondary dimensions
ridge_height = 1.5;
ridge_inset = 1.5;
label_height = 0.5;

// Screws & posts
screw_od = 2.0; //2.3
screwhead_od = 3.8;
screwpost_od = 4.0;
screw_shrink = 0.3;

// Clearances
clearance_lid = 0.3;
clearance_pcb = 0.2;
clearance_postxy = 0.2;
clearance_postz = 0.1;
clearance_screw = 0.1;
clearance_snap = 0.1;

// PCB parameters
pcb_thick = 1.2;
pcb_ypos = 0.5;
pcb_zpos = 5.7;
pcb_cardedge_width = 58;

// DIP switch dimensions
dip_n = 4;
dip_x = 23;
dip_y = 29;
dip_t = 3.6;
dip_angle = 90;
dip_w = 6.6;
dip_h = 2.54*dip_n + 1.2;
dip_rim_top = true;
dip_rim_bottom = false;
dip_rim_left = false;
dip_rim_right = true;

// Fixing positions
screws = [
    [-30,13.5], [30,13.5], [-30,32], [30,40]
];
snaps = [
    [-1, 10.5], [1, 10.5], [-1, 29], [1, 38]
];

// Calculated
detail = $preview ? 4 : 16;
below_pcb = pcb_zpos - clearance_pcb;
above_pcb = pcb_zpos + pcb_thick + clearance_pcb;
cover_zsize = below_pcb;
max_height = handle_height+ridge_height+1;
print_spacing = 5;
epsilon = 0.05;
screwhole_id = screwhead_od + 2*clearance_screw;

// Viewport centering
//$vpt = [0, profile_front/2, max_height/2];

module profile_curve(detail) {
    fnc = round(detail * 360 / curve_angle_range);
    translate([curve_xc,curve_yc,0])
    rotate([0,0,curve_angle_start])
    rotate_extrude(angle=curve_angle_range,
        convexity=5,$fn=fnc)
    translate([-curve_yc,0])
    children();
}

module main_profile(pocket, detail) {
    inset_xy = pocket ? wall_xy : 0;
    inset_z = pocket ? wall_z : 0;
    fdepth = profile_front-inset_xy;
    fslant = profile_handle_slant;
    tdepth = profile_handle_depth+inset_xy;
    fheight = handle_height-inset_z;
    theight = main_height-inset_z
        - (pocket ? label_height : 0);
    fcham = profile_handle_chamfer
        - max(inset_xy, inset_z);
    union() {
        hull() {
            polygon([
                [tdepth, 0], [fdepth, 0],
                [tdepth, fheight]
            ]);
            ch = fheight-fcham;
            sl = fslant*ch;
            translate([fdepth-sl-fcham, ch])
            intersection() {
                circle(r=fcham, $fn=detail*4);
                square(fcham+1);
            }
        }
        polygon([
            [0, 0], [tdepth+1, 0], 
            [tdepth+1, theight],
            [0, theight]
        ]);
    }
}

module side_profile(pocket, detail) {
    r1 = 1;
    h1 = main_height;
    h2 = handle_height;
    d1 = profile_front;
    slot_depth = 8;
    back = pocket ? slot_depth-epsilon : r1+1;
    union() {
        if(!pocket) hull() {
            polygon([
                [0, 0], [r1+2, 0],
                [r1+2, h1]
            ]);
            translate([r1, h1-r1])
            circle(r=r1, $fn=detail*4);
        }
        polygon([
            [back, 0], [d1, 0],
            [d1, h2], [back, h2]
        ]);
    }
}

module slant_profile(inset) {
    sp_height = max_height;
    x1 = main_xsize/2-inset;
    x2 = x1 - sp_height*main_xslant;
    polygon([
        [-x1, 0], [x1, 0],
        [x2, sp_height], [-x2, sp_height]
    ]);
}

module ridges(detail) {
    base = handle_height;
    sidegap = ridge_inset+(base*main_xslant);
    max_depth = profile_front;
    ridge_depth = 4;
    ridge_slant = 0.05;
    a = profile_handle_depth;
    b = a + ridge_depth*1/3;
    c = a + ridge_depth*2/3;
    d = a + ridge_depth;
    sl = ridge_slant * ridge_height;
    cx = main_xsize/2;
    intersection() {
        translate([-cx+sidegap, 0, 0])
        cube([main_xsize - 2*sidegap,
            max_depth, ridge_height+base]);
        profile_curve(detail*4){
            polygon([
                [a, 0],
                [b+sl, 0],
                [b+sl, base],
                [b, base+ridge_height],
                [a, base+ridge_height]
            ]);
            polygon([
                [c-sl, 0],
                [d, 0],
                [d, base+ridge_height],
                [c, base+ridge_height],
                [c-sl, base]
            ]);
        }
    }
}

module label(detail) {
    cheight = main_height;
    lheight = label_height;
    topgap = enh_label_top ? wall_xy : 0;
    bottomgap = wall_xy;
    sidegap = wall_xy+(cheight*main_xslant);
    cdepth = profile_handle_depth - topgap;
    lwidth = main_xsize-2*sidegap;
    cx = main_xsize/2;
    difference() {
        intersection() {
            profile_curve(detail*4) polygon([
                [0, cheight-lheight-1],
                [cdepth, cheight-lheight-1],
                [cdepth, cheight+1],
                [0, cheight+1]
            ]);
            translate([-cx+sidegap, bottomgap,
                cheight-lheight])
            cube([lwidth, cdepth+1,
                lheight+epsilon]);
        }
        if(enh_dipswitch) dip_hole(detail, true);
    }
}

module lock_notch(inset) {
    case_xsize = main_xsize/2-inset;
    xsize = 3;
    ysize = 8 + inset*1.41;
    zsize = main_height - wall_z;
    slant = 0.01 * zsize;
    ypos = 27.5-inset;
    translate([case_xsize,ypos,-epsilon])
    hull() {
        linear_extrude(epsilon)
        polygon([
            [-xsize, 0],
            [epsilon, 0],
            [epsilon, ysize+slant+epsilon],
            [-xsize, ysize+slant-xsize]
        ]);
        translate([0,0,zsize])
        linear_extrude(epsilon)
        polygon([
            [-xsize, 0],
            [epsilon, 0],
            [epsilon, ysize+epsilon],
            [-xsize, ysize-xsize]
        ]);
    }
}

module slot_cutout() {
    inset = wall_xy;
    height = main_height-wall_z;
    cutout_width = main_xsize-2*inset;
    depth = 8+epsilon;
    cx = main_xsize/2;
    translate([inset-cx,-epsilon,-epsilon])
    cube([cutout_width, depth+epsilon, height]);
}

module dip_hole(detail, negative) {
    max_side = 100;
    rim_radius = 1.0;
    c_w = dip_w +
        (negative ? rim_radius*2 : 0);
    c_h = dip_h +
        (negative ? rim_radius*2 : 0);
    corner_radius = negative ? rim_radius : 0.25;
    shrink = negative ? 0 : corner_radius*2*0.5;
    fn = detail * (negative ? 4 : 2);
    translate([dip_x, dip_y+pcb_ypos])
    minkowski() {
        rotate([0, 0, dip_angle])
        minkowski() {
            translate([0, 0, max_height/2])
            cube([c_w-shrink, c_h-shrink,
                max_height], true);
            if(corner_radius > 0)
            cylinder(r=corner_radius, h=1, $fn=fn);
        }
        if(negative) {
            rexx = dip_rim_left ? -max_side : 0;
            rexy = dip_rim_bottom ? -max_side : 0;
            rexw = (dip_rim_left ? max_side : 0)
                + (dip_rim_right ? max_side : 0)
                + 0.001;
            rexh = (dip_rim_top ? max_side : 0)
                + (dip_rim_bottom ? max_side : 0)
                + 0.001;
            translate([rexx, rexy, 0])
            cube([rexw, rexh, 1]);
        }
    }
}

module snapfit(indent) {
    extra_inset = indent ? clearance_snap : 0;
    snap_xsize = clearance_lid + 0.5;
    snap_zsizet = snap_xsize;
    snap_zsizeb = 1.5;
    snap_zpos = 2.0;
    snap_ysize = 2.0 + (indent ? 2*clearance_lid : 0);
    snap_inset = wall_xy + extra_inset;
    epsilon = 0.01;
    zeb = epsilon * snap_zsizeb/snap_xsize;
    zet = epsilon * snap_zsizet/snap_xsize;
    for(snap = snaps) {
        sxsign = -sign(snap[0]);
        sx = -main_xsize/2 + snap_inset;
        sy = snap[1];
        translate([sx*sxsign, sy, snap_zpos])
        rotate([90,0,0])
        linear_extrude(snap_ysize,
            center=true)
        polygon([
            [-epsilon*sxsign, -snap_zsizeb-zeb],
            [snap_xsize*sxsign, 0],
            [-epsilon*sxsign, snap_zsizet+zet]
        ]);
    }
}

module main_internal_additions(detail) {
    // Screw posts
    post_id = screw_od - screw_shrink;
    post_base = cover_zsize - 1 + clearance_postz;
    cx = main_xsize/2;
    for(post = screws)
    difference() {
        union() {
            // Posts
            translate([post[0], post[1], post_base])
            cylinder(d=screwpost_od,h=max_height,
                $fn=detail);
            // Supports
            sw = cx - abs(post[0]);
            sd = screwpost_od;
            sx = (post[0]<0) ?
                post[0]-sw : post[0];
            sy = post[1] - screwpost_od/2;
            //support_base = pcb_zpos;
            support_base = post_base;
            if(enh_post_supports)
            translate([sx, sy, support_base])
            cube([sw, screwpost_od, max_height]);
        }
        // Holes in posts
        translate([post[0], post[1],
            post_base-epsilon])
        cylinder(d=post_id,h=max_height,
            $fn=detail/2);
    }
    // Slot stop
    sstop_iw = pcb_cardedge_width + clearance_pcb*2;
    slot_depth = 8;
    sstop_ow = (main_xsize-sstop_iw)/2;
    union() {
        // Low sides
        translate([-cx, slot_depth, below_pcb+0.2])
        cube([sstop_ow, wall_xy, max_height]);
        translate([cx-sstop_ow, slot_depth,
            below_pcb+0.2])
        cube([sstop_ow, wall_xy, max_height]);
        // High middle
        translate([-cx, slot_depth, above_pcb])
        cube([main_xsize, wall_xy, max_height]);
        // Support
        zs = max_height;
        zp = above_pcb + 0.25;
        translate([0, slot_depth+wall_xy, zp])
        rotate([0,90,0])
        rotate([0,0,90])
        linear_extrude(wall_supp, center=true)
        polygon([
            [-epsilon,0],
            [0,0],
            [zs,zs],
            [-epsilon,zs]
        ]);
    }
    // Board support
    board_supports = [[-10,34.2],[10,37.2]];
    translate([-wall_supp/2, 0, above_pcb])
    for(supp = board_supports) {
        translate([supp[0], supp[1], 0])
        cube([wall_supp, 20, max_height]);
    }
    // Pegs and peg supports
    peg_xsep = 60;
    peg_y = 23.5;
    peg_z = enh_pegs_to_slots
        ? (cover_zsize + clearance_postz)
        : below_pcb-0.2;
    peg_supp_z = enh_pegs_to_slots ? peg_z : above_pcb;
    peg_d = 1.2;
    peg_supp_thick = enh_pegs_to_slots
        ? peg_d : wall_supp;
    peg_supp_width = (main_xsize-peg_xsep)/2;
    translate([-peg_xsep/2, peg_y, peg_z])
    cylinder(d=peg_d, h=max_height, $fn=detail/2);
    translate([peg_xsep/2, peg_y, peg_z])
    cylinder(d=peg_d, h=max_height, $fn=detail/2);
    translate([-cx, peg_y-peg_supp_thick/2, peg_supp_z])
    cube([peg_supp_width, peg_supp_thick, peg_supp_z]);
    translate([cx-peg_supp_width,
        peg_y-peg_supp_thick/2, peg_supp_z])
    cube([peg_supp_width, peg_supp_thick, peg_supp_z]);
    // Snap fit bumps
    if(enh_snapfit) snapfit(false);
}

module main_subtractions(detail) {
    if(enh_dipswitch) {
        dip_hole(detail, false);
    }
}

module main_shape(pocket, detail) {
    inset = pocket ? wall_xy : 0;
    inset_notch = pocket ? wall_notch : 0;
    xsize = main_xsize - 2*inset;
    translate([0, 0, pocket ? -0.01 : 0])
    intersection() {
        difference() {
            union() {
                intersection() {
                    profile_curve(detail*4)
                    main_profile(pocket, detail*2);
                    
                    rotate([0, 0, 90])
                    rotate([90, 0, 0])
                    linear_extrude(xsize, center=true,
                        convexity=5)
                    side_profile(pocket, detail);
                }
                if(!pocket) ridges(detail);
                if(pocket) slot_cutout();
            }
            if(!pocket) label(detail);
            lock_notch(inset_notch);
            if(pocket)
                main_internal_additions(detail*4);
        }
        rotate([90,0,0])
        translate([0,0,-50])
        linear_extrude(51) slant_profile(inset);
    }
}

module main(detail) {
    difference() {
        main_shape(false, detail);
        main_shape(true, detail);
        main_subtractions(detail);
    }
}

module cover_internal_additions(detail) {
    // Screw hole surrounds
    screwhole_top_id = screwpost_od+clearance_postxy*2;
    screw_surround_od = screwhole_top_id+wall_supp*2;
    for(post = screws) union() {
        // Posts
        translate([post[0], post[1], 0])
        cylinder(d=screw_surround_od,
            h=max_height, $fn=detail);
        // Supports
        if(enh_post_supports) {
            sw = main_xsize/2 - abs(post[0]);
            sd = screw_surround_od;
            sx = (post[0]<0) ?
                post[0]-sw : post[0];
            sy = post[1] - screw_surround_od/2;
            translate([sx, sy, 0])
            cube([sw, screw_surround_od, max_height]);
        }
    }
    // Board support
    board_supports = [[-10,34.2],[10,37.2]];
    translate([-wall_supp/2, 0, 0])
    for(supp = board_supports) {
        translate([supp[0], supp[1], 0])
        cube([wall_supp, 20, max_height]);
    }
    // Slot support
    slot_depth = 8;
    zs = max_height;
    zp = below_pcb - 0.25;
    translate([0, slot_depth+wall_xy, zp])
    rotate([0,-90,0])
    rotate([0,0,90])
    linear_extrude(wall_supp, center=true)
    polygon([
        [-epsilon,0],
        [0,0],
        [zs,zs],
        [-epsilon,zs]
    ]);
}

module cover_subtractions(detail) {
    // Screw holes
    screwhole_bottom_height = cover_zsize-2;
    screwhole_top_height = cover_zsize-1;
    screwhole_top_id = screwpost_od+clearance_postxy*2;
    for(hole = screws) {
        // Bottom and through-hole
        translate([hole[0], hole[1], 0]) {
            if(!enh_noholes)
            translate([0, 0, -epsilon])
            cylinder(d=screwhole_id,
                h=screwhole_bottom_height,
                $fn=detail);
            translate([0, 0, wall_z])
            cylinder(d=screw_od+clearance_screw*2,
                h=max_height, $fn=detail/2);
        }
        // Posts
        translate([hole[0], hole[1], 
            screwhole_top_height])
        cylinder(d=screwhole_top_id,
            h=max_height, $fn=detail);        
        // Supports
        if(enh_post_supports) {
            sw = main_xsize/2 - abs(hole[0]);
            sd = screwhole_top_id;
            sx = (hole[0]<0) ?
                hole[0]-sw : hole[0];
            sy = hole[1] - screwhole_top_id/2;
            translate([sx, sy, screwhole_top_height])
            cube([sw, screwhole_top_id, max_height]);
        }
    }
    // Snapfit indents
    if(enh_snapfit) snapfit(true);
}

module cover_shape(pocket, detail) {
    inset_base = wall_xy + clearance_lid;
    inset = inset_base + (pocket ? wall_xy : 0);
    xsize = main_xsize - 2*inset;
    max_y = profile_front;
    cx = main_xsize/2;
    difference() {
        translate([0, 0, pocket ? wall_z : 0])
        union() {
            if(!pocket) intersection() {
                rotate([0,0,90])
                rotate([90,0,0])
                linear_extrude(main_xsize, center=true)
                square([8+epsilon, wall_z]);
                
                rotate([90,0,0])
                translate([0,0,-50])
                linear_extrude(50)
                slant_profile(inset);
            }
            intersection() {
                inset2 = inset+(cover_zsize
                    *profile_handle_slant);
                profile_curve(detail*4)
                polygon([
                    [0,0], [max_y-inset,0],
                    [max_y-inset2, cover_zsize],
                    [0, cover_zsize]
                ]);
                
                translate([-xsize/2,
                    8+inset-inset_base, 0])
                cube([xsize, 50, cover_zsize]);
                
                if(!pocket) {
                    rotate([90,0,0])
                    translate([0,0,-50])
                    linear_extrude(50)
                    slant_profile(inset);
                }
            }
        }
        lock_notch(inset+wall_notch-wall_xy);
        if(pocket) cover_internal_additions(detail*4);
    }
}

module cover(detail) {
    difference() {
        cover_shape(false, detail);
        cover_shape(true, detail);
        cover_subtractions(detail*4);
    }
}

module pcb_preview() {
    // Board
    //color("#383")
    color("#348")
    translate([0, 0.5, pcb_zpos])
    linear_extrude(pcb_thick)
    difference() {
        polygon([
            [29,0], [29,13], [30,15.25],
            [32.5,15.25], [32.5,25.5],
            [29.5,25.5], [29.5,39.5],
            [27.75,39.5], [27.75,41],
            [14,40.1],[0,38.5],[-14,36.4],
            [-27.75,33.5], [-27.75,31.5],
            [-30,29.25], [-32.5,29.25],
            [-32.5,15.25], [-30,15.25],
            [-29,13], [-29,0]
        ]);
        translate([-30,23])
        circle(d=1.5,$fn=16);
        translate([30,23])
        circle(d=1.5,$fn=16);
        translate([-30,13])
        circle(d=4.5,$fn=16);
        translate([-30,31.5])
        circle(d=4.5,$fn=16);
        translate([30,39.5])
        circle(d=4.5,$fn=16);
        translate([30,13])
        circle(d=4.5,$fn=16);
    }
    // DIP switches
    if(enh_dipswitch)
    translate([dip_x, pcb_ypos+dip_y,
        pcb_zpos+pcb_thick])
    rotate([0, 0, dip_angle]) {
        // Main block
        color("#333")
        translate([-dip_w/2, -dip_h/2, 0])
        cube([dip_w, dip_h, dip_t]);
        // Switches
        color("#EEE")
        for(n = [0 : dip_n-1]) {
            yo = (n-(dip_n-1)/2) * 2.54;
            translate([-1.5,yo-0.6,dip_t])
            cube([1.0, 1.2, 0.8]);
        }
        // Pins
        color("#FE8")
        for(n = [0 : dip_n-1]) {
            yo = (n-(dip_n-1)/2) * 2.54;
            translate([-3.81-0.1,yo-0.4,-2.5])
            cube([0.2, 0.8, 4]);
            translate([3.81-0.1,yo-0.4,-2.5])
            cube([0.2, 0.8, 4]);
            translate([-3.81-0.1,yo-0.7,0.2])
            cube([7.62+0.2, 1.4, 1.3]);
        }
    }
}

dx = print_spacing + main_xsize - wall_xy
    - clearance_lid;
if($preview) {
    pcb_preview();
    color("#ACE", 0.55) {
        if(prerender) {
            translate([preview_print ? dx : 0,
                0, 0])
            render(convexity=3)
            cover(detail);
            render(convexity=3)
            main(detail);
        } else {
            cover(detail);
            main(detail);
        }
    }
} else {
    union() {
        if(render_main) main(detail);
        if(render_cover)
        translate([render_main ? dx : 0, 0, 0])
        cover(detail);
    }
}