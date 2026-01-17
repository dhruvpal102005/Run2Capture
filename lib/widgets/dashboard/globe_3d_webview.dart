import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Globe3DWebView - Matches TypeScript Globe3DWebView.tsx exactly
/// Uses Three.js via WebView for 3D globe rendering
class Globe3DWebView extends StatefulWidget {
  final double userLat;
  final double userLng;
  final List<Territory>? territories;
  final VoidCallback? onGlobeReady;

  const Globe3DWebView({
    super.key,
    required this.userLat,
    required this.userLng,
    this.territories,
    this.onGlobeReady,
  });

  @override
  State<Globe3DWebView> createState() => Globe3DWebViewState();
}

class Globe3DWebViewState extends State<Globe3DWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF05090D))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            widget.onGlobeReady?.call();
          },
        ),
      )
      ..loadHtmlString(_getGlobeHTML(widget.userLat, widget.userLng));
  }

  /// Zoom to location - exposed for parent component
  void zoomToLocation(double lat, double lng) {
    _controller.runJavaScript('window.zoomToLocation($lat, $lng);');
  }

  /// Get HTML/JS for 3D Globe - matches TypeScript getGlobeHTML() exactly
  String _getGlobeHTML(double userLat, double userLng) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            background: #05090d; 
            overflow: hidden;
            touch-action: none;
        }
        canvas { display: block; }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #4a9eff;
            font-family: Arial, sans-serif;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div id="loading">Loading Globe...</div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        const userLat = $userLat;
        const userLng = $userLng;
        
        // Hide loading
        document.getElementById('loading').style.display = 'none';
        
        // Scene setup
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 1000);
        camera.position.z = 4;
        
        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setClearColor(0x05090d, 1);
        renderer.setPixelRatio(window.devicePixelRatio);
        document.body.appendChild(renderer.domElement);
        
        // Lighting
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
        scene.add(ambientLight);
        
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(5, 3, 5);
        scene.add(directionalLight);
        
        // Stars
        const starsGeometry = new THREE.BufferGeometry();
        const starPositions = new Float32Array(3000);
        for (let i = 0; i < 1000; i++) {
            const radius = 50 + Math.random() * 50;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.acos(2 * Math.random() - 1);
            starPositions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
            starPositions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            starPositions[i * 3 + 2] = radius * Math.cos(phi);
        }
        starsGeometry.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
        const starsMaterial = new THREE.PointsMaterial({ size: 0.3, color: 0xffffff });
        const stars = new THREE.Points(starsGeometry, starsMaterial);
        scene.add(stars);
        
        // Load real Earth texture
        const textureLoader = new THREE.TextureLoader();
        
        // Earth sphere
        const earthGeometry = new THREE.SphereGeometry(1.5, 64, 64);
        const earthMaterial = new THREE.MeshStandardMaterial({
            color: 0x1a4538,
            roughness: 0.7,
            metalness: 0.1,
        });
        const earth = new THREE.Mesh(earthGeometry, earthMaterial);
        scene.add(earth);
        
        // Load NASA Blue Marble Earth texture
        textureLoader.load(
            'https://unpkg.com/three-globe@2.31.1/example/img/earth-night.jpg',
            function(texture) {
                earthMaterial.map = texture;
                earthMaterial.color.setHex(0xffffff);
                earthMaterial.needsUpdate = true;
            },
            undefined,
            function(error) {
                console.log('Texture load failed, using fallback');
            }
        );
        
        // Atmosphere glow
        const glowGeometry = new THREE.SphereGeometry(1.58, 64, 64);
        const glowMaterial = new THREE.MeshBasicMaterial({
            color: 0x4a9eff,
            transparent: true,
            opacity: 0.12,
            side: THREE.BackSide,
        });
        const glow = new THREE.Mesh(glowGeometry, glowMaterial);
        scene.add(glow);
        
        // Outer glow ring
        const outerGlowGeometry = new THREE.SphereGeometry(1.68, 64, 64);
        const outerGlowMaterial = new THREE.MeshBasicMaterial({
            color: 0x4a9eff,
            transparent: true,
            opacity: 0.05,
            side: THREE.BackSide,
        });
        const outerGlow = new THREE.Mesh(outerGlowGeometry, outerGlowMaterial);
        scene.add(outerGlow);
        
        // Convert lat/lng to 3D position
        function latLngToVector3(lat, lng, radius) {
            const phi = (90 - lat) * (Math.PI / 180);
            const theta = (lng + 180) * (Math.PI / 180);
            const x = -(radius * Math.sin(phi) * Math.cos(theta));
            const z = radius * Math.sin(phi) * Math.sin(theta);
            const y = radius * Math.cos(phi);
            return new THREE.Vector3(x, y, z);
        }
        
        // User location marker
        const markerPos = latLngToVector3(userLat, userLng, 1.55);
        const markerGeometry = new THREE.SphereGeometry(0.04, 16, 16);
        const markerMaterial = new THREE.MeshBasicMaterial({ color: 0x3B82F6 });
        const marker = new THREE.Mesh(markerGeometry, markerMaterial);
        marker.position.copy(markerPos);
        scene.add(marker);
        
        // Marker glow
        const markerGlowGeometry = new THREE.SphereGeometry(0.08, 16, 16);
        const markerGlowMaterial = new THREE.MeshBasicMaterial({
            color: 0x3B82F6,
            transparent: true,
            opacity: 0.4,
        });
        const markerGlow = new THREE.Mesh(markerGlowGeometry, markerGlowMaterial);
        markerGlow.position.copy(markerPos);
        scene.add(markerGlow);
        
        // Touch controls
        let isDragging = false;
        let isPinching = false;
        let previousTouchX = 0;
        let previousTouchY = 0;
        let previousPinchDistance = 0;
        let rotationVelocityX = 0;
        let rotationVelocityY = 0.002;
        let targetCameraZ = 4;
        const minZoom = 2.5;
        const maxZoom = 8;
        const maxRotationX = Math.PI / 3;
        
        function getTouchDistance(touches) {
            const dx = touches[0].clientX - touches[1].clientX;
            const dy = touches[0].clientY - touches[1].clientY;
            return Math.sqrt(dx * dx + dy * dy);
        }
        
        document.addEventListener('touchstart', (e) => {
            if (e.touches.length === 2) {
                isPinching = true;
                isDragging = false;
                previousPinchDistance = getTouchDistance(e.touches);
            } else if (e.touches.length === 1) {
                isDragging = true;
                isPinching = false;
                previousTouchX = e.touches[0].clientX;
                previousTouchY = e.touches[0].clientY;
                rotationVelocityY = 0;
                rotationVelocityX = 0;
            }
        });
        
        document.addEventListener('touchmove', (e) => {
            if (isPinching && e.touches.length === 2) {
                const currentDistance = getTouchDistance(e.touches);
                const delta = currentDistance - previousPinchDistance;
                targetCameraZ -= delta * 0.01;
                targetCameraZ = Math.max(minZoom, Math.min(maxZoom, targetCameraZ));
                previousPinchDistance = currentDistance;
            } else if (isDragging && e.touches.length === 1) {
                const deltaX = e.touches[0].clientX - previousTouchX;
                const deltaY = e.touches[0].clientY - previousTouchY;
                
                earth.rotation.y += deltaX * 0.005;
                glow.rotation.y += deltaX * 0.005;
                outerGlow.rotation.y += deltaX * 0.005;
                
                const newRotationX = earth.rotation.x + deltaY * 0.005;
                if (Math.abs(newRotationX) < maxRotationX) {
                    earth.rotation.x = newRotationX;
                    glow.rotation.x = newRotationX;
                    outerGlow.rotation.x = newRotationX;
                }
                
                previousTouchX = e.touches[0].clientX;
                previousTouchY = e.touches[0].clientY;
                rotationVelocityY = deltaX * 0.001;
                rotationVelocityX = deltaY * 0.001;
            }
        });
        
        document.addEventListener('touchend', (e) => {
            if (e.touches.length === 0) {
                isDragging = false;
                isPinching = false;
                if (Math.abs(rotationVelocityY) < 0.001) {
                    rotationVelocityY = 0.002;
                }
            } else if (e.touches.length === 1) {
                isPinching = false;
                isDragging = true;
                previousTouchX = e.touches[0].clientX;
                previousTouchY = e.touches[0].clientY;
            }
        });
        
        // Animation
        let time = 0;
        function animate() {
            requestAnimationFrame(animate);
            time += 0.016;
            
            camera.position.z += (targetCameraZ - camera.position.z) * 0.1;
            
            if (!isDragging && !isPinching) {
                earth.rotation.y += rotationVelocityY;
                glow.rotation.y += rotationVelocityY;
                outerGlow.rotation.y += rotationVelocityY;
                
                const newRotationX = earth.rotation.x + rotationVelocityX;
                if (Math.abs(newRotationX) < maxRotationX) {
                    earth.rotation.x = newRotationX;
                    glow.rotation.x = newRotationX;
                    outerGlow.rotation.x = newRotationX;
                } else {
                    rotationVelocityX = 0;
                }
                
                if (Math.abs(rotationVelocityY) > 0.002) {
                    rotationVelocityY *= 0.98;
                }
                if (Math.abs(rotationVelocityX) > 0.001) {
                    rotationVelocityX *= 0.98;
                } else {
                    rotationVelocityX = 0;
                }
            }
            
            // Pulse marker
            const scale = 1 + Math.sin(time * 3) * 0.3;
            marker.scale.set(scale, scale, scale);
            markerGlow.scale.set(scale, scale, scale);
            
            // Update marker position with earth rotation
            const rotatedMarkerPos = markerPos.clone()
                .applyAxisAngle(new THREE.Vector3(0, 1, 0), earth.rotation.y)
                .applyAxisAngle(new THREE.Vector3(1, 0, 0), earth.rotation.x);
            marker.position.copy(rotatedMarkerPos);
            markerGlow.position.copy(rotatedMarkerPos);
            
            renderer.render(scene, camera);
        }
        
        animate();
        
        // Handle resize
        window.addEventListener('resize', () => {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        });
        
        // Zoom function exposed to Flutter
        window.zoomToLocation = function(lat, lng) {
            console.log('Zooming to location:', lat, lng);
            
            rotationVelocityY = 0;
            rotationVelocityX = 0;
            
            const startRotationY = earth.rotation.y;
            const startRotationX = earth.rotation.x;
            const startCameraZ = camera.position.z;
            const targetCameraZValue = 2.8;
            
            const markerTheta = (lng + 180) * Math.PI / 180;
            const targetTheta = Math.PI / 2;
            const targetRotationY = targetTheta - markerTheta;
            const targetRotationX = 0;
            
            let rotationDiffY = targetRotationY - startRotationY;
            let rotationDiffX = targetRotationX - startRotationX;
            
            while (rotationDiffY > Math.PI) rotationDiffY -= Math.PI * 2;
            while (rotationDiffY < -Math.PI) rotationDiffY += Math.PI * 2;
            
            let progress = 0;
            const duration = 1200;
            const startTime = Date.now();
            
            const baseMarkerPos = latLngToVector3(lat, lng, 1.55);
            
            function animateZoom() {
                const elapsed = Date.now() - startTime;
                progress = Math.min(elapsed / duration, 1);
                
                const eased = progress < 0.5 
                    ? 4 * progress * progress * progress 
                    : 1 - Math.pow(-2 * progress + 2, 3) / 2;
                
                const currentRotY = startRotationY + rotationDiffY * eased;
                const currentRotX = startRotationX + rotationDiffX * eased;
                
                earth.rotation.y = currentRotY;
                earth.rotation.x = currentRotX;
                glow.rotation.y = currentRotY;
                glow.rotation.x = currentRotX;
                outerGlow.rotation.y = currentRotY;
                outerGlow.rotation.x = currentRotX;
                
                camera.position.z = startCameraZ + (targetCameraZValue - startCameraZ) * eased;
                
                const rotatedMarkerPos = baseMarkerPos.clone()
                    .applyAxisAngle(new THREE.Vector3(0, 1, 0), currentRotY)
                    .applyAxisAngle(new THREE.Vector3(1, 0, 0), currentRotX);
                marker.position.copy(rotatedMarkerPos);
                markerGlow.position.copy(rotatedMarkerPos);
                
                if (progress < 1) {
                    requestAnimationFrame(animateZoom);
                } else {
                    targetCameraZ = targetCameraZValue;
                    setTimeout(() => {
                        rotationVelocityY = 0.002;
                    }, 500);
                }
            }
            
            animateZoom();
        };
    </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: const Color(0xFF05090D),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A9EFF),
              ),
            ),
          ),
      ],
    );
  }
}

/// Territory data model
class Territory {
  final List<LatLng> coordinates;
  final Color color;

  Territory({required this.coordinates, required this.color});
}

/// LatLng helper
class LatLng {
  final double latitude;
  final double longitude;
  LatLng({required this.latitude, required this.longitude});
}
