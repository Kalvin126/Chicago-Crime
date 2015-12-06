//
//  MapVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

enum ChicagoBoundary : String {
    case City = "City"
    case Neighborhood = "Neighborhood"
    case None = "None"
}

protocol MapVCDelegate {
    func mapVC(mapVC: MapVC, showDetailVCForAnnotation annotation:MKAnnotation)
}

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var delegate: MapVCDelegate?

    var cityBoundary: ChicagoBoundary = .City
    var boundaryOverlays: [MKPolygon] = []

    var crimes:Array<Report> = []
    var schools:Array<School> = []
    var schoolRadius:Double = 1609 // meters
    var radiusOverlays:[MKCircle] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsScale = true

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.8570092871228, -87.6975366951543)
        let span = MKCoordinateSpanMake(0.4, 0.7)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)

        showBoundaryWithDataSet("chicago_boundaries")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let gradientView:UIView = UIView(frame: CGRect(x: 0, y: view.frame.size.height-30, width: 400, height: 30))
        gradientView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        gradLayer?.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradLayer!, above: view.layer)

        view.insertSubview(gradientView, aboveSubview: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helper

    func addReports(reports: Array<Report>) {
        clearReports()

        crimes += reports
        mapView.addAnnotations(reports)
    }

    func clearReports() {
        mapView.removeAnnotations(crimes)
        crimes.removeAll()
    }

    func addSchools(schools: Array<School>) {
        // remove overlays
        for c in radiusOverlays {
            mapView.removeOverlay(c)
        }
        radiusOverlays.removeAll()
        
        clearSchools()

        self.schools += schools
        mapView.addAnnotations(schools)
    }

    func clearSchools() {
        mapView.removeAnnotations(schools)
        schools.removeAll()
    }

    func clearBoundaries() {
        mapView.removeOverlays(boundaryOverlays)
        boundaryOverlays.removeAll()
    }

    func showBoundaryWithDataSet(set: String) {
        clearBoundaries()

        let path = NSBundle.mainBundle().pathForResource(set, ofType: "json")
        let json = JSON(data: NSData(contentsOfFile: path!)!)

        let timeStart:NSDate = NSDate()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            for (_, sJson) in json {
                var points:[CLLocationCoordinate2D] = []
                for (_, ssJson) in sJson["the_geom"]["coordinates"][0][0] {
                    points += [CLLocationCoordinate2DMake(ssJson[1].double!, ssJson[0].double!)]
                }

                self.boundaryOverlays += [MKPolygon(coordinates: &points, count: points.count)]
            }

            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addOverlays(self.boundaryOverlays)

                let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(timeStart)
                print("Boundary load and plot finished in \(interval) seconds")
            }
        }
    }
    
    func addRadiusCircle(location: CLLocationCoordinate2D){
        let circle = MKCircle(centerCoordinate: location, radius: schoolRadius as CLLocationDistance)
        let lat = circle.coordinate.latitude
        let lon = circle.coordinate.longitude
        for i in 0..<radiusOverlays.count {
            let c = radiusOverlays[i].coordinate
            if lat == c.latitude && lon == c.longitude {
                // overlay is already on screen
                mapView.removeOverlay(radiusOverlays[i])
                radiusOverlays.removeAtIndex(i)
                return
            }
        }
        self.mapView.addOverlay(circle)
        radiusOverlays.append(circle)
    }

    // MARK: IBActions

    @IBAction func tappedBoundaryButton(sender: UIButton) {
        cityBoundary = { () -> ChicagoBoundary in
            switch self.cityBoundary {
            case .City:
                showBoundaryWithDataSet("chicago_boundaries_neighborhood")
                return .Neighborhood

            case .Neighborhood:
                clearBoundaries()
                return .None

            case .None:
                showBoundaryWithDataSet("chicago_boundaries")
                return .City
            }
        }()

        sender.setTitle(cityBoundary.rawValue, forState: .Normal)
    }

    @IBAction func tappedMapTypeButton(sender: UIButton) {
        let nextType = MKMapType(rawValue: mapView.mapType.rawValue + UInt(1))!
        mapView.mapType = mapView.mapType == .HybridFlyover ? .Standard : nextType

        switch mapView.mapType {
        case .Standard:
            sender.setTitle("Standard", forState: .Normal)
            break

        case .Satellite:
            sender.setTitle("Satellite", forState: .Normal)
            break

        case .Hybrid:
            sender.setTitle("Hybrid", forState: .Normal)
            break

        case .SatelliteFlyover:
            sender.setTitle("Satellite Flyover", forState: .Normal)
            break

        case .HybridFlyover:
            sender.setTitle("Hybrid Flyover", forState: .Normal)
            break
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is Report:
            return (annotation as! Report).mapAnnotationView()

        case is School:
            let annoView:MKAnnotationView = (annotation as! School).mapAnnotationView()

            let colorTint:UIColor = gradLayer!.colorForRatio((annotation as! School).selectedAttributeFloat())
            
            annoView.tintColor = colorTint
            return annoView
            
        default:
            return nil
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView annotView: MKAnnotationView) {
        delegate?.mapVC(self, showDetailVCForAnnotation: annotView.annotation!)
        let anno:MKAnnotation = annotView.annotation!
        
        if anno is School {
            let school:School = annotView.annotation as! School
            addRadiusCircle(school.coordinate)
        }
        
        
        
        annotView.highlighted = true
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: poly)
            renderer.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
            renderer.strokeColor = UIColor.blackColor()
            renderer.lineWidth = 2

            return renderer
        } else  if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }
        
        return MKOverlayRenderer()
    }
}
