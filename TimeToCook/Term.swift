//
//  Term.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 4/26/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

class Term {
    private var name:String = ""
    private var definition:String = ""
    
    init(name:String, definition:String) {
        self.name = name
        self.definition = definition
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setName(name:String) {
        self.name = name
    }
    
    func getDefinition() -> String {
        return self.definition
    }
    
    func setDefinition(definition:String) {
        self.definition = definition
    }
    
    static func getTermList() -> [Term] {
        
        var terms:[Term] = [Term]()
        
        terms.append(Term(name: "Al Dente", definition: "Italian term used to describe pasta that is cooked until it offers a slight resistance to the bite."))
        terms.append(Term(name: "Bake", definition: "To cook by dry heat, usually in the oven."))
        terms.append(Term(name: "Barbecue", definition: "Usually used generally to refer to grilling done outdoors or over an open charcoal or wood fire. More specifically, barbecue refers to long, slow direct- heat cooking, including liberal basting with a barbecue sauce."))
        terms.append(Term(name: "Baste", definition: "To moisten foods during cooking with pan drippings or special sauce to add flavor and prevent drying."))
        terms.append(Term(name: "Batter", definition: "A mixture containing flour and liquid, thin enough to pour."))
        terms.append(Term(name: "Beat", definition: "To mix rapidly in order to make a mixture smooth and light by incorporating as much air as possible."))
        terms.append(Term(name: "Blanch", definition: "To immerse in rapidly boiling water and allow to cook slightly."))
        terms.append(Term(name: "Blend", definition: "To incorporate two or more ingredients thoroughly."))
        terms.append(Term(name: "Boil", definition: "To heat a liquid until bubbles break continually on the surface."))
        terms.append(Term(name: "Broil", definition: "To cook on a grill under strong, direct heat."))
        terms.append(Term(name: "Caramelize", definition: "To heat sugar in order to turn it brown and give it a special taste."))
        terms.append(Term(name: "Chop", definition: "To cut solids into pieces with a sharp knife or other chopping device."))
        terms.append(Term(name: "Clarify", definition: "To separate and remove solids from a liquid, thus making it clear."))
        terms.append(Term(name: "Cream", definition: "To soften a fat, especially butter, by beating it at room temperature. Butter and sugar are often creamed together, making a smooth, soft paste."))
        terms.append(Term(name: "Cure", definition: "To preserve meats by drying and salting and/or smoking."))
        terms.append(Term(name: "Deglaze", definition: "To dissolve the thin glaze of juices and brown bits on the surface of a pan in which food has been fried, sauteed or roasted. To do this, add liquid and stir and scrape over high heat, thereby adding flavor to the liquid for use as a sauce."))
        terms.append(Term(name: "Degrease", definition: "To remove fat from the surface of stews, soups, or stock. Usually cooled in the refrigerator so that fat hardens and is easily removed."))
        terms.append(Term(name: "Dice", definition: "To cut food in small cubes of uniform size and shape."))
        terms.append(Term(name: "Dissolve", definition: "To cause a dry substance to pass into solution in a liquid."))
        terms.append(Term(name: "Dredge", definition: "To sprinkle or coat with flour or other fine substance."))
        terms.append(Term(name: "Drizzle", definition: "To sprinkle drops of liquid lightly over food in a casual manner."))
        terms.append(Term(name: "Dust", definition: "To sprinkle food with dry ingredients. Use a strainer or a jar with a perforated cover, or try the good, old-fashioned way of shaking things together in a paper bag."))
        terms.append(Term(name: "Fillet", definition: "As a verb, to remove the bones from meat or fish. A fillet (or filet) is the piece of flesh after it has been boned."))
        terms.append(Term(name: "Flake", definition: "To break lightly into small pieces."))
        terms.append(Term(name: "Flambe'", definition: "To flame foods by dousing in some form of potable alcohol and setting alight."))
        terms.append(Term(name: "Fold", definition: "To incorporate a delicate substance, such as whipped cream or beaten egg whites, into another substance without releasing air bubbles. Cut down through mixture with spoon, whisk, or fork; go across bottom of bowl, up and over, close to surface. The process is repeated, while slowing rotating the bowl, until the ingredients are thoroughly blended."))
        terms.append(Term(name: "Fricassee", definition: "To cook by braising; usually applied to fowl or rabbit."))
        terms.append(Term(name: "Fry", definition: "To cook in hot fat. To cook in a fat is called pan-frying or sauteing; to cook in a one-to-two inch layer of hot fat is called shallow-fat frying; to cook in a deep layer of hot fat is called deep-fat frying."))
        terms.append(Term(name: "Garnish", definition: "To decorate a dish both to enhance its appearance and to provide a flavorful foil. Parsley, lemon slices, raw vegetables, chopped chives, and other herbs are all forms of garnishes."))
        terms.append(Term(name: "Glaze", definition: "To cook with a thin sugar syrup cooked to crack stage; mixture may be thickened slightly. Also, to cover with a thin, glossy icing."))
        terms.append(Term(name: "Grate", definition: "To rub on a grater that separates the food in various sizes of bits or shreds."))
        terms.append(Term(name: "Gratin", definition: "From the French word for \"crust.\" Term used to describe any oven-baked dish--usually cooked in a shallow oval gratin dish--on which a golden brown crust of bread crumbs, cheese or creamy sauce is form."))
        terms.append(Term(name: "Grill", definition: "To cook on a grill over intense heat."))
        terms.append(Term(name: "Grind", definition: "To process solids by hand or mechanically to reduce them to tiny particles."))
        terms.append(Term(name: "Julienne", definition: "To cut vegetables, fruits, or cheeses into thin strips."))
        terms.append(Term(name: "Knead", definition: "To work and press dough with the palms of the hands or mechanically, to develop the gluten in the flour."))
        terms.append(Term(name: "Lukewarm", definition: "Neither cool nor warm; approximately body temperature."))
        terms.append(Term(name: "Marinate", definition: "To flavor and moisturize pieces of meat, poultry, seafood or vegetable by soaking them in or brushing them with a liquid mixture of seasonings known as a marinade. Dry marinade mixtures composed of salt, pepper, herbs or spices may also be rubbed into meat, poultry or seafood."))
        terms.append(Term(name: "Meuniere", definition: "Dredged with flour and sauteed in butter."))
        terms.append(Term(name: "Mince", definition: "To cut or chop food into extremely small pieces."))
        terms.append(Term(name: "Mix", definition: "To combine ingredients usually by stirring."))
        terms.append(Term(name: "Pan-broil", definition: "To cook uncovered in a hot fry pan, pouring off fat as it accumulates."))
        terms.append(Term(name: "Pan-fry", definition: "To cook in small amounts of fat."))
        terms.append(Term(name: "Parboil", definition: "To boil until partially cooked; to blanch. Usually this procedure is followed by final cooking in a seasoned sauce."))
        terms.append(Term(name: "Pare", definition: "To remove the outermost skin of a fruit or vegetable."))
        terms.append(Term(name: "Peel", definition: "To remove the peels from vegetables or fruits."))
        terms.append(Term(name: "Pickle", definition: "To preserve meats, vegetables, and fruits in brine."))
        terms.append(Term(name: "Pinch", definition: "A pinch is the trifling amount you can hold between your thumb and forefinger."))
        terms.append(Term(name: "Pit", definition: "To remove pits from fruits."))
        terms.append(Term(name: "Planked", definition: "Cooked on a thick hardwood plank."))
        terms.append(Term(name: "Plump", definition: "To soak dried fruits in liquid until they swell."))
        terms.append(Term(name: "Poach", definition: "To cook very gently in hot liquid kept just below the boiling point."))
        terms.append(Term(name: "Puree", definition: "To mash foods until perfectly smooth by hand, by rubbing through a sieve or food mill, or by whirling in a blender or food processor."))
        terms.append(Term(name: "Reduce", definition: "To boil down to reduce the volume."))
        terms.append(Term(name: "Refresh", definition: "To run cold water over food that has been parboiled, to stop the cooking process quickly."))
        terms.append(Term(name: "Render", definition: "To make solid fat into liquid by melting it slowly."))
        terms.append(Term(name: "Roast", definition: "To cook by dry heat in an oven."))
        terms.append(Term(name: "Saute", definition: "To cook and/or brown food in a small amount of hot fat."))
        terms.append(Term(name: "Scald", definition: "To bring to a temperature just below the boiling point."))
        terms.append(Term(name: "Scallop", definition: "To bake a food, usually in a casserole, with sauce or other liquid. Crumbs often are sprinkled over."))
        terms.append(Term(name: "Score", definition: "To cut narrow grooves or gashes partway through the outer surface of food."))
        terms.append(Term(name: "Sear", definition: "To brown very quickly by intense heat. This method increases shrinkage but develops flavor and improves appearance."))
        terms.append(Term(name: "Shred", definition: "To cut or tear in small, long, narrow pieces."))
        terms.append(Term(name: "Sift", definition: "To put one or more dry ingredients through a sieve or sifter."))
        terms.append(Term(name: "Simmer", definition: "To cook slowly in liquid over low heat at a temperature of about 180°. The surface of the liquid should be barely moving, broken from time to time by slowly rising bubbles."))
        terms.append(Term(name: "Skim", definition: "To remove impurities, whether scum or fat, from the surface of a liquid during cooking, thereby resulting in a clear, cleaner-tasting final produce."))
        terms.append(Term(name: "Steam", definition: "To cook in steam in a pressure cooker, deep well cooker, double boiler, or a steamer made by fitting a rack in a kettle with a tight cover. A small amount of boiling water is used, more water being added during steaming process, if necessary."))
        terms.append(Term(name: "Steep", definition: "To extract color, flavor, or other qualities from a substance by leaving it in water just below the boiling point."))
        terms.append(Term(name: "Sterilize", definition: "To destroy micro organisms by boiling, dry heat, or steam."))
        terms.append(Term(name: "Stew", definition: "To simmer slowly in a small amount of liquid for a long time."))
        terms.append(Term(name: "Stir", definition: "To mix ingredients with a circular motion until well blended or of uniform consistency."))
        terms.append(Term(name: "Toss", definition: "To combine ingredients with a lifting motion."))
        terms.append(Term(name: "Truss", definition: "To secure poultry with string or skewers, to hold its shape while cooking."))
        terms.append(Term(name: "Whip", definition: "To beat rapidly to incorporate air and produce expansion, as in heavy cream or egg whites."))
        
        return terms
    }
}